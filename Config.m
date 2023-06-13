classdef Config < handle
    
    properties (SetAccess = protected)
        screen; % Screen ID corresponding to slm
        res; % Resolution of the slm in pixel
        pitch; % Separation between two pixels from centers
        bckgrnd_phase; % Phase to always apply to a pattern. Use this to correct for flaws in the SLM screen.
        focal_length; % Effective focal length of the imaging lenses in mm (must be given for proper control of tweezers).
        wl; % Wavelength in mm
    end
    
    methods (Static)

        function config = Debug(varargin)
            % Creates a config for use in testing. 
            config = Config('res',[512,512],'screen',0,varargin{:});
        end
        
        function config = LCR2500(varargin)
            % Creates configuration for LC-R 2500 Holoeye SLM.
            config = Config('res',[768,1024],'pitch',19,varargin{:});
        end 

        function config = Multiscale(varargin)
            % Creates configuration for LC-R 2500 Holoeye SLM on Multiscale
            % Microscope
            config = Config.LCR2500('wl',473,'bckgrnd_phase',zeros(768,1024),varargin{:});
        end

        function config = BNS(varargin)
            % Creates configuration for BNS SLM.
            config = Config('res',[1536,1536],'pitch',10,varargin{:});
        end
            
        function config = BEAM(varargin)
            % Creates configuration for BNS SLM for 2 Photon Stimulation.
            config = Config.BEAM('wl',1024,'bckgrnd_phase',zeros(1536,1536),varargin{:});
        end
    end 
    
    methods
        
        function self = Config(varargin)
          % Class for storing parameters of SLM setup.
          %
          % Optional named parameters:
          %   - 'screen' int -- Screen device ID.
          %     Default: `2` 
          %   - 'res' [r1,r2]  -- Screen resolution in pixels.
          %     Default: `[100, 100]`
          %   - 'pitch' float -- Spacing of pixels in um.
          %     Default: `[10,10]`
          %   - 'bckgrnd_phase' float -- Matrix of phase values 
          %     normalized from 0 to 1.
          %     Default: `[]` 
          %   - 'focal_length' float -- Effective focal length of setup in mm.
          %      Should be Inf if a virtual lens is being used to image
          %      onto a camera. If a real lens is in use, enter its
          %      focal length.
          %     Default: `Inf`
          %   - 'wl' float -- Wavelength of laser in nm.
          %     Default: `633`

            p = inputParser;
            p.addParameter('screen', 2);  
            p.addParameter('res', [100,100]); % in pixels
            p.addParameter('pitch', 10); % in um
            p.addParameter('bckgrnd_phase', []); 
            p.addParameter('focal_length', Inf); % in mm;
            p.addParameter('wl', 633); % in nm
            p.parse(varargin{:});
            
            self.screen= p.Results.screen;
            self.res= p.Results.res;
            self.pitch= p.Results.pitch; %in mm
            self.focal_length= p.Results.focal_length; % in mm
            self.wl= p.Results.wl; %in mm

            if isempty(p.Results.bckgrnd_phase)
                self.bckgrnd_phase= zeros(self.res);
            else
                assert(isequal(self.res,size(p.Results.bckgrnd_phase)),"Background phase must have same dims as res.");
                self.bckgrnd_phase= p.Results.bckgrnd_phase;
            end
        end 

        function set.screen(self, id)
            % Set method for screen ID.
            %
            % Parameters
            % - id, integer ID of screen to use.

            self.screen= id;
            if id>size(get(groot,'MonitorPositions'),1)
                self.screen= 1;
            end
        end

        function set.res(self, res)
            % Set method for screen resolution.
            %
            % Parameters
            % -res, 1x2 screen resolution in pixels.

            assert(isequal(size(res),[1,2]),"Resolution should be 1x2 array.")
            assert(all(mod(res, 2) == 0), "Resolution must be even.");
            self.res= res;
        end

        function set.pitch(self, pitch)
            % Set method for pixel pitch.
            %
            % Parameters
            % - pitch, spacing of pixel centers in um.

            assert(isfloat(pitch) && isscalar(pitch),"Pitch should be a scalar float");
            self.pitch= pitch*1e-3;
        end

        function set.focal_length(self, focal_length)
            % Set method for focal_length.
            %
            % Parameters
            % - focal_length, Effective focal length of real lenses after
            %   SLM in mm.

            assert(isfloat(focal_length) && isscalar(focal_length),"Focal length should be a scalar float");
            self.focal_length= focal_length;
        end

        function set.wl(self, wl)
            % Set method for light wavelength.
            %
            % Parameters
            % - wl, wavelength of the incident light in nm.

            assert(isfloat(wl) && isscalar(wl),"Wavelength should be a scalar float.");
            self.wl= wl*1e-6;
        end

    end 
    
end 
