classdef OpticalPatterns < handle

    properties (SetAccess = protected)
        X; Y; % Meshgrid of a 2D screen.
        rho; theta; % Radial and angular meshgrids of a 2D screen.
    end

    methods (Static)

        function [X,Y] = meshgrid(res, varargin)
            % Creates a meshgrid for a screen resolution.
            %
            % Parameters
            % -res, pixel resolution of image.
            %
            % Optional named parameters:
            %   - 'x0' int  -- X-axis origin. 
            %     Default: `res(2)+1)/2`
            %   - 'y0' int  -- Y-axis origin. 
            %     Default: `res(1)+1)/2`

            p = inputParser;
            p.addParameter('x0', (res(2)+1)/2);
            p.addParameter('y0', (res(1)+1)/2);
            p.parse(varargin{:});

            linx= linspace(0, res(2)-1, res(2))+0.5;
            liny= linspace(0, res(1)-1, res(1))+0.5;
            [X,Y]= meshgrid(linx,liny);
            
            X= X-p.Results.x0;
            Y= Y-p.Results.y0;
        end
        
        function img = window(res, dt, varargin)
            % Creates a binary border around an image.
            % Use with Gerchberg-Saxton algorithm.
            %
            % Parameters
            % -res, pixel resolution of image.
            % -dt, pixel thickness of window.
            %
            % Optional named parameters:
            %   - 'dx' int  -- Border thickness along x-axis. 
            %     Default: `1`
            %   - 'dy' int  -- Border thickness along y-axis. 
            %     Default: `1`
            
            p = inputParser;
            p.addParameter('dx', 1);
            p.addParameter('dy', 1);
            p.parse(varargin{:});
            dx= p.Results.dx;
            dy= p.Results.dy;
            
            assert(isequal(size(res),[1,2]));
            img= uint8(zeros(res));
            img(dy:dy+dt,dx:end-dx)= 1;
            img(dy:end-dy,dx:dx+dt)= 1;
            img(end-dy-dt:end-dy,dx:end-dx)= 1;
            img(dy:end-dy,end-dx-dt:end-dx)= 1;
        end

        function img = crosshair(res, dt)
            % Creates a centered binary crosshair pattern.
            % Use with Gerchberg-Saxton algorithm.
            %
            % Parameters
            % -res, pixel resolution of image.
            % -dt, pixel thickness of crosshair lines.
            
            assert(isequal(size(res),[1,2]) && all(mod(res, 2)==0));
            assert(dt>=2 && mod(dt,2)==0);

            img= zeros(res);
            img((res(1)-dt)/2:(res(1)+dt)/2,:)= 1;
            img(:,(res(2)-dt)/2:(res(2)+dt)/2)= 1;
        end
        
        function img = spots(res, points, r)
            % Creates a binary pattern of spots.
            % Use with Gerchberg-Saxton algorithm.
            %
            % Parameters
            % -res, pixel resolution of image.
            % -points, Nx2 array containing centers of each dot.
            % -r, radius of a dot.
            
            assert(size(points, 2) == 2);
            points(:, 1) = 0.5*(res(1)+1)*points(:, 1)+res(1)/2; 
            points(:, 2) = 0.5*(res(2)+1)*points(:, 2)+res(2)/2;
            
            P= points(1,:);
            img= otslm.simple.aperture(res, r, 'centre', [P(2),P(1)]);
            for i= 2:size(points,1)
                P= points(i,:);
                img =img|otslm.simple.aperture(res, r, 'centre', [P(2),P(1)]);
            end
        end

    end

    methods

        function self = OpticalPatterns(res, varargin)
            % Constructs a new OpticalPatterns class instance.
            %
            % Parameters
            % -res, pixel resolution of optical patterns to produce.
            %
            % Optional named parameters:
            %   - 'x0' int  -- X-axis origin. 
            %     Default: `res(2)+1)/2`
            %   - 'y0' int  -- Y-axis origin. 
            %     Default: `res(1)+1)/2`

            [self.X,self.Y]= self.meshgrid(res, varargin{:});
            self.rho= sqrt((self.X).^2 + (self.Y).^2);
            self.theta= atan2(self.Y, self.X);
        end

        function lens = fresnel_lens(self, f, wl)
            % Creates virtual lens for focusing image along z-axis.
            % 
            % Parameters
            % - f, Focal length in mm. Choose to be ~distance to image plane. 
            % - wl, Wavelength of incident light in mm.

            lens = sign(f)*(sqrt(f.^2 + self.config.pitch^2*(self.rho.^2)) - abs(f))/wl;
        end

        function grating = blazed_grating(self, dx, dy, varargin)
            % Creates a blazed grating phase mask. This can be used to translate a
            % pattern in the xy-plane.
            %
            % Parameter
            % - dx, Grating period in pixels along x-axis.
            % - dy, Grating period in pixels along y-axis.

            assert(isscalar(dx) || isscalar(dy));
            if dx~=0 && dy==0
                grating= (self.X)/dx;
            elseif dx==0 && dy~=0
                grating= (self.Y)/dy;
            else
                grating= (self.X)/dx + (self.Y)/dy;
            end
        end

        function grating = binary_grating(self, dx, dy, varargin)
            % Creates a binary grating phase mask.
            %
            % Parameter
            % - dx, Grating period in pixels along x-axis.
            % - dy, Grating period in pixels along y-axis.

            assert(isscalar(dx) || iscalar(dy));
            if dx~=0 && dy==0
                grating= (mod(self.X,dx*2)<dx).*0.5;
            elseif dx==0 && dy~=0
                grating= (mod(self.Y,dy*2)<dy).*0.5;
            else
                grating= mod((mod(self.Y,dy*2)<dy).*0.5 + (mod(self.X,dx*2)<dx).*0.5,1);
            end
        end

        function LG_l0 = vortex(self, l)
            % Creates an optical vortex phase mask.
            %
            % Parameter
            % - l, angular momentum of optical vortex..
            
            LG_l0= self.theta.*l;
        end

        function ax = axicon(self, G)
            % Creates an axicon phase mask.
            %
            % Parameter
            % - G, gradient of axicon pattern.
          
            ax= -self.rho.*G;
        end

    end

end

      