classdef SLM < otslm.utils.ScreenDevice & OpticalTweezers
    % Class for displaying images to SLM.
    % Dependent on ScreenDevice class from OTSLM.

    properties (SetAccess = protected)
        mask; % Additional phase mask to apply to current state.
        LUT; % Look up table function.
    end
    
    methods (Static)
                
        function pattern = combine_phases(patterns,phase)
            % Applies virtual lens to phase pattern(s).
            %
            % Parameters
            % - patterns, a single 2D matrix or cell array of 2D matrices
            %   giving phase masks to apply virtual lens to.
            % - phase, 2D matrix giving a phase mask 
            
            if iscell(patterns)
                pattern= cellfun(@(x)mod(x+phase,1),patterns,'un',0);
            else
                pattern= mod(patterns + phase, 1);
            end
        end

    end
    
    methods (Access = protected)
        
        function target = preprocess(self, target)
            % Checks and preprocesses target patterns.
            %
            % Parameters
            % - target, 2D matrix corresponding to a target pattern.

            d= size(target);
            if length(d) ~=2
                error('Expecting 2D Target');
            end 
            if ~all(mod(size(target), 2) == 0)
                error('Target Must Have an Even Resolution');
            end
            if d(1) > self.config.res(1) || d(2) > self.config.res(2)
                target= self.crop(target);
            end
            if d(1) < self.config.res(1) || d(2) < self.config.res(2)
                target= self.pad(target);
            end
        end
        
    end 

    methods

        function self = SLM(config, varargin)
            % Constructs a new SLM class instance.
            %
            % Parameters
            % - config, Config class instance that gives all 
            %   setup specific parameters.
            %
            % Optional named parameters:
            %   - 'center' [r,c]  -- Offset within the window.  Negative
            %     values are offset from the top of the screen.
            %     Default: `[res(1)+1)/2, res(2)+1)/2]`
            %   - 'f' float -- Focal length of virtual lens to apply [mm]. 
            %     Default: `Inf`
            %   - 'LUT' @(X) Y -- Look up table implemented as a function.
            %     This function maps a normalized phase between 0 & 1 to a
            %     pixel value. X and Y are matrices.
            %     Default: `@(phase) uint8(round(phase.*255)`

            p = inputParser;
            p.addParameter('LUT', @(phase) uint8(round(phase.*255)) );
            p.KeepUnmatched= true;
            p.parse(varargin{:});
            
            self = self@otslm.utils.ScreenDevice(config.screen, 'size', config.res, ...
              'pattern_type', 'phase', 'fullscreen', true, 'prescaledPatterns', false);
            self = self@OpticalTweezers(config, varargin{:} );
      
            self.mask= config.bckgrnd_phase;
            self.LUT= p.Results.LUT;
            self.show_null();
        end
        
        function reset_mask(self)
            % Resets the phase mask to its default state.
            %
            self.mask= self.config.bckgrnd_phase;
        end

        function sz = size(self)
            % Returns the pixel resolution of the SLM display.
            %
            sz = self.config.res;
        end

        function pattern = encode(self, phase)
           % Turn a phase pattern into a proper grayscale RGB phase mask.
           %
           % Parameters
           % - phase, a single 2D matrix or cell array of 2D matrices
           %   to be turned into grayscaled images.
           %

            if iscell(phase)
                pattern= cell(1,size(phase,2));
                for i=1:size(phase,2)
                   phi= self.LUT(phase);
                   pattern{i}= repmat(phi,[1,1,3]);
                end
            else
                phase= self.LUT(phase);
                pattern= repmat(phase,[1,1,3]);
            end 
        end

        function phase = compute_phasemask(self, target, varargin)
          % Calculates phase mask for a target image.
          %
          % Parameters
          % - target, 2D matrix for which phase pattern will be calculated.
          %
          % Optional named parameters:
          %   - 'incident' matrix -- Function that takes a 2D size and
          %      returns a matrix giving the incident intensity pattern. 
          %     Default: `@(res) ones(res)` (uniform intensity)
          %   - 'alpha' int -- Adaptive additive factor. 1 for 
          %     normal GS algorithm.
          %     Default: `1` 
          %   - 'N' int  -- Number of iterations to perfrom GS algorithm.
          %     Default: `10`
          %   - 'padding' int -- Padding to add to all images when
          %      performing calculations. 
          %     Default: `100`
          %   - 'use_gpu' bool -- Whether to use gpu to calculate phase mask. 
          %     Default: `false`
          %   - 'parallel', bool -- If multiple targets are given and this
          %     is true, then patterns are calculated in parallel. 

            p = inputParser;
            p.addParameter('incident', @(res) ones(res) );
            p.addParameter('alpha', 1);
            p.addParameter('N', 10);
            p.addParameter('padding', 100);
            p.addParameter('use_gpu', false);
            p.parse(varargin{:});
            
            target= self.preprocess(target);
            padding= [p.Results.padding,p.Results.padding];
            target= padarray(self.resize(target),padding,0,'both');
            I= p.Results.incident(size(target));
            if p.Results.use_gpu
                target= gpuArray(target);
                I= gpuArray(I);
            end
            
            phase = self.crop(gs_algorithm.gerchberg_saxton(I,target,p.Results.alpha,p.Results.N)./(2*pi)); %normalize phase
        end  
        
        function show_null(self, varargin)
            % Displays a null phase pattern on the SLM.
            %
            % Optional named parameters:
            %   - 't' float -- Time to display image. If negative, the
            %   image will remain until closed.
            %   Default: `-1`
            
            p = inputParser;
            p.addParameter('t', -1);
            p.parse(varargin{:});
            
            self.close();
            self.showRaw('pattern',self.encode(zeros(self.config.res)));
            if p.Results.t >= 0
                pause(p.Results.t);
                self.close();
            end
        end

        function show(self, phase, varargin) 
            % Displays phase pattern on SLM.
            %
            % Parameters
            % - phase, 2D matrix giving phase mask. Phases should 
            %   be normalized to be within 0-1 corresponding to 0-2pi.
            %
            % Optional named parameters:
            %   - 't' float -- Time to display image. If negative, the
            %   image will remain until closed.
            %   Default: `-1`
            %   - 'encode' bool -- If the input needs to be converted to a
            %   proper RGB image.
            %   Default: `true`
            
            p = inputParser;
            p.addParameter('encode', true);
            p.addParameter('t', -1);
            p.parse(varargin{:});
            
            if p.Results.encode
                assert(isequal(size(phase),self.config.res),'Provided phase pattern must have correct dimensions.');
            else
                assert(isequal(size(phase), ... 
                    [self.config.res(1),self.config.res(2),3]),'Provided phase pattern must have correct dimensions.');
            end

            if p.Results.encode
                if ~isinf(self.f)
                   lens= self.fresnel_lens(self.f,self.config.wl);
                   phase= self.combine_phases(phase,lens);
                end
    
                phase= self.combine_phases(phase,self.mask);
                pattern= self.encode(phase);
            else
                pattern= phase;
            end
            self.showRaw('pattern',pattern);
            if p.Results.t >= 0
                pause(p.Results.t);
                self.show_null();
            end
            self.reset_mask();
        end

        function play(self, frames, varargin)
            % Displays a movie of phase patterns on SLM.
            %
            % Parameter
            % - frames, Cell array of 2D matrices corresponding to invidividual frames. 
            %   Phases should be normalized to be within 0-1 corresponding to 0-2pi.
            %
            % Optional named parameters:
            %   - 'fps' float -- Framerate to use.
            %   Default: `1`
            
            p = inputParser;
            p.addParameter('fps', 1);
            p.parse(varargin{:}); 
            
            N= size(frames,2);
            if isinf(self.config.focal_length) && ~isinf(self.f)
               lens= self.fresnel_lens(self.f,self.config.wl);
               frames= self.combine_phases(frames,lens);
            end

            frames= self.combine_phases(frames,self.mask);
            frames= self.encode(frames);
            F = struct('cdata', {}, 'colormap', {});
            for i= 1:N
              F(i) = im2frame(frames{i});
            end
        
            self.showRaw('pattern',F,'framerate',p.Results.fps);
            pause(1/p.Results.fps);
            self.show_null();
        end 
        
        function simulate_scattering(self, M)
            % Creates and stores a phasemask that is applied
            % to approximate light scattering through a medium.
            %
            % Parameter
            %  - M, an integer whose relative size compared to the SLM
            %   determines the degree of scattering.
            
            N= max(self.size());
            assert(M<N, "M must be less than the SLM resolution.");
            assert(mod(M,2)==0, "Only even M is supported.");
            
            scattering= self.crop(utils.phasemask(N,M));
            self.mask= self.mask + scattering;
        end

        function apply_zernike(self, varargin)
            % Performs aberration correction with Zernike polynomials.
            % Result is stored in internal phase mask which is applied when 
            % a pattern is displayed.
            %
            % Optional named parameters:
            %  - 'piston', vtilt, htilt, obl_astimatism', 'defocus', 'astigmatism',
            %    'vtrefoil', 'vcoma', 'hcoma', 'obl_trefoil', 'obl_trefoil, 
            %    'obl_quadrafoil', 'obl_astigmatism2', 'spherical', 'astigmatism2',
            %    'vquadrafoil' float -- Coefficient to multiply Zernike polynomial
            %     by.
            %
            % See https://en.wikipedia.org/wiki/Zernike_polynomials for more info

            Z= utils.aberration(self.config.res,varargin{:});
            self.mask= self.mask - Z;
        end

        function apply_grating(self, D, binary)
            % Creates and stores a grating phase mask that is applied to
            % the pattern when displayed. This can be used to translate a
            % pattern in the xy-plane.
            %
            % Parameter
            % - D, Grating period in pixels in both x & y directions [dx,dy].
            % - binary, Creates a binary grating if true and a blazed
            %   grating if false.
            
            if numel(D)==1
                D= [D,0];
            end

            assert(numel(D)==2);
            if binary
                grating= self.binary_grating(D(1),D(2));
            else
                grating= self.blazed_grating(D(1),D(2));
            end
            self.mask= self.mask + grating;
        end

    end
end 