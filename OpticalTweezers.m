classdef (Abstract) OpticalTweezers < handle
    % Abstract class for computing dynamic holographic optical tweezers (DHOTs) and then 
    % displaying them on SLM. As the SLM class inherits it.

    properties (Abstract, SetAccess = protected)
        config Config; % Config instance that stores setup parameters.
        f; % Focal length of virtual lens. Ignored if focal length given in config.
    end
    
    properties (SetAccess = protected)
       tweezers= {}; % Cell array containing individual tweezer phase masks.
       positions= {}; % Cell array of tweezer positions (it is assumed each phase mask is centered).
       zoffsets= {}; % Cell array of tweezer displacements.
       N= 0; % Number of tweezers.
    end
    
    methods (Access = protected, Static)
        
        function param = parse_twzr_param(param, ntwzrs)
            % Parses a parameter(s) for a new tweezer.
            %
            % Parameters
            % - param, float/vector tweezer specific parameter(s).
            % - ntwzrs, integer number of tweezers.

            if isscalar(param)
                param=param*ones(ntwzrs,1);
            else 
                assert(isvector(param));
                assert(length(param) == ntwzrs);
            end 
        end

    end

     methods (Access = protected)

        function pos = parse_positions(self, pos)
            % Parses a tweezer positions.
            %
            % Parameters
            % - pos, array of tweezer positions.

            assert(size(pos, 2) == 2); % check whether OTs have both x and y coordinates   
            pos(:, 1) = 0.5*(self.config.res(1))*(pos(:, 1))*self.config.pitch; 
            pos(:, 2) = 0.5*(self.config.res(2))*(pos(:, 2))*self.config.pitch;
        end
                
        function lens= zlens(self, dz)
            % Creates lens for moving beam in z-plane.
            % 
            % Parameters
            % - dz, displacement along z-axis in um.

            if ~isinf(self.config.focal_length)
               ff= self.config.focal_length;
            else
               ff= self.f;
            end

            lens= zeros(self.config.res);
            if ff>0
                lens= self.rho.^2*(dz*10^(-3))/(self.config.wl*ff^2);
            end
        end

        function lens = xylens(self, pos)
            % Creates grating lens for moving beam in xy-plane.
            % 
            % Parameters
            % - pos, normalized position of a translated point. 
            
            pos(1) = 0.25*self.config.res(1)*pos(1); 
            pos(2) = 0.25*self.config.res(2)*pos(2);
            
            if ~isinf(self.config.focal_length)
               ff= self.config.focal_length;
            else
               ff= self.f;
            end

            lens= zeros(self.config.res);
            if ff>0
                lens = lens + self.config.pitch^2*(self.X*pos(1) + self.Y*pos(2))/(self.config.wl*ff);
            end
        end 

    end 

    methods
        
        function reset(self)
           % Clears tweezer array.
           %
           reset@SLM(self);
           self.tweezers= {};
           self.positions= {};
           self.zoffsets= {};
           self.N= 0;
        end
        
        function add(self, pos, phase, dz)
          % Adds n tweezers given some arbitrary phase.
          %
          % Parameters
          % - pos, array of tweezer positions.
          % - phase, arbitrary phase pattern. 
          % - dz, z displacement of tweezers.

            if size(phase,1) ~= self.config.res(1) || size(phase,2) ~= self.config.res(2)
                error('Dimension mismatch.');
            end

            pos= self.parse_positions(pos);
            n= size(pos,1);
            dz= self.parse_twzr_param(dz,n);
            
            for i=1:n
                self.tweezers{self.N+i}= 2*pi*phase;
                self.positions{self.N+i}= pos(i,:);
                self.zoffsets{self.N+i}= dz(i);
            end
            self.N= self.N+n;
        end
        
        function add_point(self, pos, dz)
          % Adds n points.
          %
          % Parameters
          % - pos, array of tweezer positions.
          % - phase, arbitrary phase pattern. 
          % - dz, z displacement of tweezers.
            
            pos= self.parse_positions(pos);
            n= size(pos,1);
            dz= self.parse_twzr_param(dz,n);

            for i=1:n
                self.tweezers{self.N+i}= 0;
                self.positions{self.N+i}= pos(i,:);
                self.zoffsets{self.N+i}= dz(i);
            end
            self.N= self.N+n;
        end
        
        function add_vortex(self, pos, l, dz)
          % Adds n optical vortices.
          %
          % Parameters
          % - pos, array of tweezer positions.
          % - l, angular momentum of optical vortex.
          % - dz, z displacement of tweezers.

            pos= self.parse_positions(pos);
            n= size(pos,1);
            l= self.parse_twzr_param(l,n);
            dz= self.parse_twzr_param(dz,n);
            
            for i=1:n
                self.tweezers{self.N+i}= self.vortex(l(i));
                self.positions{self.N+i}= pos(i,:);
                self.zoffsets{self.N+i}= dz(i);
            end
            self.N= self.N+n;
        end
        
      function add_axicon(self, pos, G, dz)
          % Adds n axicons.
          %
          % Parameters
          % - pos, array of tweezer positions.
          % - G, gradient of axicon pattern.
          % - dz, z displacement of tweezers.

            pos= self.parse_positions(pos);
            n= size(pos,1);
            G= self.parse_twzr_param(G,n);
            dz= self.parse_twzr_param(dz,n);
            
            for i=1:n
                self.tweezers{self.N+i}= self.axicon(G(i));
                self.positions{self.N+i}= pos(i,:);
                self.zoffsets{self.N+i}= dz(i);
            end
            self.N= self.N+n;
        end
        
        function update_twzr(self, n, pos, dz)
            % Updates a single tweezer to a new position.
            %
            % Parameters
            % - n, integer specifying tweezer.
            % - pos, [x,y] positon to move tweezer to.
            % - dz, z displacement of tweezer.
            
            assert(length(pos) == 2);
            xy= self.config.pitch*[0.25*self.config.res(1)*pos(1),0.25*self.config.res(2)*pos(2)];
            self.positions{n}= xy;
            self.zoffsets{n}= dz;
        end 

        function move_twzr(self, n, pos, dz)
            % Shifts a single tweezer to a new position.
            %
            % Parameters
            % - n, integer specifying tweezer.
            % - pos, [x,y] positon to move tweezer to.
            % - dz, z displacement of tweezer.
            
            assert(length(pos) == 2);
            assert(isscalar(dz) && iscalar(n));
            xy= self.config.pitch*[0.25*self.config.res(1)*pos(1),0.25*self.config.res(2)*pos(2)];
            self.positions{n}= self.positions{n} + xy;
            self.zoffsets{n}= self.zoffsets{n} + dz;
        end 
        
        function phase = compute_tweezers(self, varargin) 
          % Calculates phase mask for optical tweezer array.
          %
          % Optional named parameters:
          %   - 'alpha' int -- Adaptive additive factor. 1 for 
          %     normal GS algorithm.
          %     Default: `1` 
          %   - 'N' int  -- Number of iterations to perfrom GS algorithm.
          %     Default: `10`
          %   - 'use_gpu' bool -- Whether to use gpu to calculate phase mask. 
          %     Default: `false`

            p = inputParser;
            p.addParameter('alpha', 1);
            p.addParameter('N', 10);
            p.addParameter('use_gpu', false);
            p.parse(varargin{:});
            
            dz= cell2mat(self.zoffsets);
            pos= transpose(cell2mat(cellfun(@(x)reshape(x,2,1),self.positions,'un',0)));
            twzrs= reshape(cell2mat(cellfun(@(x)reshape(x,self.config.res(1),self.config.res(2),[]) ... 
                ,self.tweezers,'un',0)),self.config.res(1),self.config.res(2),self.N);

            trap = zeros(self.config.res(1),self.config.res(2),self.N);
            for i=1:self.N
                trap(:,:,i) = (2*pi).*( self.xylens(pos(i,:)) + self.zlens(dz(i)) );
            end

            if p.Results.use_gpu
                components= gpuArray(trap+twzrs);
            else
                components= trap+twzrs;
            end

            phase = combo_gerchberg_saxton(components,p.Results.alpha,p.Results.N)./(2*pi); %normalize phase
        end
        
    end
end 