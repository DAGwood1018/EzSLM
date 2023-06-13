classdef OptReservoir < SLM & CamInterface
    % Implementation of an optical reservoir on an SLM.
    % Link to a Cam object and then start imaging to run this class.

    properties (SetAccess = protected)
        state % State of reservoir system.
        input % Inputs for all time steps. 
        output % Observed output reservoir states.
        sz; % Size of input+reservoir system.

        spacing= 2; % Sampling grid spacing.
        threshold= 0; % Intensity threshold.
        bias= 0; % Bias phase.
        t= -1; % Current time.
        dt= 0.15; % Delay between updates.
    end

    % These methods implement CamInterface
    methods (Access = public)
        
        function frame = acquire_frame(self, vidinput, frame_count)
            % Acquires most recent frame(s) from a videoinput object and 
            % process the input.
            %
            % Parameters
            % - vidinput, videoinput object to retrieve frames from.
            % - frame_count, integer number of frames to acquire and
            %   average over.

           if frame_count>1
              img= double(getdata(vidinput,frame_count));
              img= uint8(round(mean(img,4),0)); 
           else
              img= uint8(getdata(vidinput,1));
           end
<<<<<<< HEAD
           figure(1);
           imshow(img);
=======

>>>>>>> 5fac894f1683998025b4112813eb41c6dfe584f9
           img(img<self.threshold)= 0;
           frame= self.sample(img);
        end

        function update_from_cam(self, frame)
            % Updates the system state based on the input acquired from
            % imaging data.
            %
            % Parameters
            % - frame, vector input corresponding to the encoded reservoir
            % state at time t.
 
            if self.t<1
               error("Must initialize system before running"); 
            end
            
            self.output(:,self.t)= frame;
            x_t= double(frame)./255;
            self.update_reservoir(x_t);
       
            if self.t<length(self.input)
                self.t= self.t+1;
                self.update_input(self.input(self.t));
                self.show(self.state);
                pause(self.dt);
            end
        end
        
        function stop = stopnow(self)
           % Stops image acquisition from the camera.

           stop = false;
           if self.t > 0
            if self.t >= length(self.input)
                disp("Optical reservoir use completed")
                stop = true;
                self.t = -1;
            end
           end
        end

    end
    
    methods (Access = protected)
        
        function update_input(self, i_t)
            % Updates phase mask to reflect a new input.
            %
            % Parameters
            % - i_t, scalar input for time t. 
            % (this could be generalized to a vector input)

            assert(i_t>=0 && i_t<=1, "Inputs must be normalized.")
            res= self.size();
            bx= (res(2)-self.sz(2))/2;
            by= (res(1)-self.sz(1))/2;
            if self.sz(2)>=self.sz(1)
                half= self.sz(2)/2 + bx;
                self.state( by + 1 : end-by, bx + 1 : half )= i_t;
            else
                half= self.sz(1)/2 + by;
                self.state( by + 1 : half, bx+1 : end-bx)= i_t;
            end
        end

        function update_reservoir(self, x_t)
            % Updates phase mask to reflect a new reservoir state.
            %
            % Parameters
            % - x_t, vector input corresponding to the encoded reservoir
            % state at time t.

            assert(length(x_t)==(self.sz(1)*self.sz(2)/2), "Input size doesn't match reservoir size");
            assert(all(x_t>=0) && all(x_t<=1), "State must be normalized")
            
            res= self.size();
            bx= (res(2)-self.sz(2))/2;
            by= (res(1)-self.sz(1))/2;
            if self.sz(2)>=self.sz(1)
                half= self.sz(2)/2 + bx;
                x_t= reshape(x_t, [self.sz(1), self.sz(2)/2]);
                self.state( by + 1 : end-by, half + 1 : end-bx )= x_t;
            else
                half= self.sz(1)/2 + by;
                x_t= reshape(x_t, [self.sz(1)/2, self.sz(2)]);
                self.state( half + 1 : end-by, bx+1 : end-bx)= x_t;
            end
        end

        function pxls = sample(self, img)
            % Samples pixels on a grid of the specified spacing. Will fail
            % if the spacing is too large.
            %
            % Parameters
            % - img, Image of the current reserovir state to sample.

            npxls= self.sz(2)*self.sz(1)/2;
            img= img(1:self.spacing:end,1:self.spacing:end);
            if size(img,1)*size(img,2)<npxls
                error("Sampling grid is too large for the given image resolution.");
            end

            n= ceil(sqrt(npxls));
            img= utils.cropim(img,[n,n]);
            img= reshape(img, [], 1);
            pxls= img(1:npxls); 
        end
        
    end
    
    methods 
        
        function self = OptReservoir(config, varargin)
            % Constructs a new OptRes class instance.
            %
            % Parameters
            % - config, Config class instance that gives all 
            %   setup specific parameters.
            %
            % Optional named parameters:
            %   - 'sz' [N,M]  -- Size of region to reserve on the SLM to
            %     represent reservoir system.
            %     Default: `[256,256]`
            %   - 'bias' float -- Phase between 0 and 1 to use as a bias. 
            %     Default: `0`
            %   - 'spacing' int -- Even pixel spacing for sampling grid.
            %     Default: `2`
            %   - 'threshold' float -- All intensity levels below the
            %      threshold are set to 0.
            %     Default: `0.0`
            %   - 'dt' -- Time to wait between updates to the system [s]. 
            %     Default: `0.05`
         
            p = inputParser;
            p.KeepUnmatched = true;
            p.addParameter('sz', [256,256]);
            p.addParameter('bias', 0);
            p.addParameter('spacing', 2);
            p.addParameter('threshold', 0.0);
            p.addParameter('dt', 0.05);
            p.parse(varargin{:});
            
            unmatched = [fieldnames(p.Unmatched).'; struct2cell(p.Unmatched).'];
            self = self@SLM(config, 'LUT', @(phase) uint8(round(phase.*255)), unmatched{:});

            self.threshold= p.Results.threshold;
            self.bias= p.Results.bias;
            self.dt= p.Results.dt;
            self.spacing= p.Results.spacing;
            self.state= self.bias.*ones(self.size());
            
            % Verify size of the reservoir system
            SZ= self.size();
            assert(length(p.Results.sz)==2,"sz must be an array of length = 2");
            assert(all(mod(p.Results.sz,2)==0) && all(p.Results.sz>0),"sz must be > 0 and % 2 = 0");
            assert(p.Results.sz(1)<=SZ(1) && p.Results.sz(2)<=SZ(2), "sz must be smaller the screen size");
            self.sz= p.Results.sz;
        end
        
        function set.bias(self, bias)
            % Set method for bias property.
            %
            % Parameters
            % - bias, float between 0 & 1 that is used as the bias (background)
            %   phase when the system is displayed. 

            if isfloat(bias)
                if bias>=0 && bias<=1
                    self.bias= bias;
                end
            end
        end
        
        function set.threshold(self, threshold)
           % Set method for threshold property.
           %
           % Parameters
           % - threshold, intensity value (8bit) below which the intensity
           %   is set to zero.

           if isnumeric(threshold)
              if threshold>=0
                  self.threshold= threshold;
              end
           end
        end
        
        function set.dt(self, dt)
            % Set method for dt property
            %
            % Parameters
            % - dt, time in seconds to wait between updates to the system.

            if isnumeric(dt)
                if dt>=0
                   self.dt= dt;
                end
            end
        end

        function set.spacing(self, spacing)
            % Set method for sampling grid spacing property
            %
            % Parameters
            % - spcaing, integer grid spacing to use when sampling the
            %   pixels of an imaged state.

            if isnumeric(spacing)
                if spacing>=2 && mod(spacing,2)==0
                    self.spacing= spacing;
                end
            end
        end

        function initialize(self, input)
            % Initialize reservoir system. Only after this function is
            % called will the object run when a camera is recording.
            %
            % Parameters
            % - input, array of inputs for some number of time steps.
            % - output, video writer object to store observed output to.
            %
            % *This could be generalized to vector inputs.

            self.t= 1;
            if self.sz(2)>=self.sz(1)
                s = [self.sz(1),self.sz(2)/2];
            else
                s = [self.sz(1)/2,self.sz(2)];
            end
            
            start_state= rand(s);
            self.input= rescale(input);
            self.output= zeros(self.sz(1)*self.sz(2)/2, ... 
                size(input,1)-1,'uint8');

            self.update_reservoir(start_state(:));
            self.update_input(self.input(1));
            self.show(self.state);
        end
        
    end
    
end