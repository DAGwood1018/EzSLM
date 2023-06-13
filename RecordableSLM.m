<<<<<<< HEAD
classdef RecordableSLM < SLM & CamInterface
    
    properties (SetAccess = protected)
        indx; % Current frame number
        phase_patterns; % Phase patterns to show
        recording; % Output video
        threshold; % Intensity threshold
        dt; % Time delay between updates in s
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
           img(img<self.threshold)= 0;
           frame= img;
        end

        function update_from_cam(self, frame)
            % Updates the system state based on the input acquired from
            % imaging data.
            %
            % Parameters
            % - frame, image taken.
 
            if self.indx<1
               error("Must initialize system before running"); 
            end
            writeVideo(self.recording,frame);
       
            if self.indx<length(self.phase_patterns)
                self.indx= self.indx+1;
                self.show(self.phase_patterns{self.indx});
                pause(self.dt);
            end
            
        end
        
        function stop = stopnow(self)
           % Stops image acquisition from the camera.

           stop = false;
           if self.indx > 0
            if self.indx >= length(self.phase_patterns)
                disp("Finished recording.")
                stop = true;
                self.indx = -1;
                close(self.recording);
            end
           end
        end
        
    end
    
    methods
        
        function self = RecordableSLM(config, varargin)
            % Constructs a new RecordableSLM class instance. Use for
            % automatic recording of a large number of computed phase
            % patterns.
            %
            % Parameters
            % - config, Config class instance that gives all 
            %   setup specific parameters.
            %
            % Optional named parameters:
            %   - 'threshold' float -- All intensity levels below the
            %      threshold are set to 0.
            %     Default: `0.0`
            %   - 'dt' -- Time to wait between updates to the system [s]. 
            %     Default: `0.05`
         
            p = inputParser;
            p.KeepUnmatched = true;
            p.addParameter('threshold', 0.0);
            p.addParameter('dt', 0.05);
            p.parse(varargin{:});
            
            unmatched = [fieldnames(p.Unmatched).'; struct2cell(p.Unmatched).'];
            self = self@SLM(config, unmatched{:});

            self.threshold= p.Results.threshold;
            self.dt= p.Results.dt;
        end
        
        function initialize(self, phase_patterns, vidoutput)
            % Initializes the class for recording.
            %
            % Parameters
            % - phase_patterns, a cell array of every phase pattern you
            % want to display and then image.
            % - vidoutput, a VideoWriter to write images taken to.

            assert( isa(vidoutput,'VideoWriter'), "No video provided to save images to.");
            
            self.phase_patterns= phase_patterns;
            self.recording= vidoutput;
            open(self.recording);

            self.indx=1;
            self.show(self.phase_patterns{self.indx});
        end
        
    end
=======
classdef RecordableSLM < SLM & CamInterface
    
    properties (SetAccess = protected)
        indx; % Current frame number
        phase_patterns; % Phase patterns to show
        recording; % Output video
        threshold; % Intensity threshold
        dt; % Time delay between updates in s
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
           img(img<self.threshold)= 0;
           frame= img;
        end

        function update_from_cam(self, frame)
            % Updates the system state based on the input acquired from
            % imaging data.
            %
            % Parameters
            % - frame, image taken.
 
            if self.indx<1
               error("Must initialize system before running"); 
            end
            writeVideo(self.recording,frame);
       
            if self.indx<length(self.phase_patterns)
                self.indx= self.indx+1;
                self.show(self.phase_patterns{self.indx});
                pause(self.dt);
            end
            
        end
        
        function stop = stopnow(self)
           % Stops image acquisition from the camera.

           stop = false;
           if self.indx > 0
            if self.indx >= length(self.phase_patterns)
                disp("Finished recording.")
                stop = true;
                self.indx = -1;
                close(self.recording);
            end
           end
        end
        
    end
    
    methods
        
        function self = RecordableSLM(config, varargin)
            % Constructs a new RecordableSLM class instance. Use for
            % automatic recording of a large number of computed phase
            % patterns.
            %
            % Parameters
            % - config, Config class instance that gives all 
            %   setup specific parameters.
            %
            % Optional named parameters:
            %   - 'threshold' float -- All intensity levels below the
            %      threshold are set to 0.
            %     Default: `0.0`
            %   - 'dt' -- Time to wait between updates to the system [s]. 
            %     Default: `0.05`
         
            p = inputParser;
            p.KeepUnmatched = true;
            p.addParameter('threshold', 0.0);
            p.addParameter('dt', 0.05);
            p.parse(varargin{:});
            
            unmatched = [fieldnames(p.Unmatched).'; struct2cell(p.Unmatched).'];
            self = self@SLM(config, unmatched{:});

            self.threshold= p.Results.threshold;
            self.dt= p.Results.dt;
        end
        
        function initialize(self, phase_patterns, vidoutput)
            % Initializes the class for recording.
            %
            % Parameters
            % - phase_patterns, a cell array of every phase pattern you
            % want to display and then image.
            % - vidoutput, a VideoWriter to write images taken to.

            assert( isa(vidoutput,'VideoWriter'), "No video provided to save images to.");
            
            self.phase_patterns= phase_patterns;
            self.recording= vidoutput;
            open(self.recording);

            self.indx=1;
            self.show(self.phase_patterns{self.indx});
        end
        
    end
>>>>>>> 5fac894f1683998025b4112813eb41c6dfe584f9
end