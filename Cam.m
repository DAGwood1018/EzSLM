classdef Cam < handle
    % Class for easily configuring a camera through Matlab.

    properties (SetAccess = protected)
        device; % Videoinput object.
    end

    methods (Static)

        function framefcn(vidinput, event, device, frame_count)
            % Implementation of a FramesAcquiredFcn that works with any
            % class implementing CamInterface.
            %
            % Parameters
            % - vidinput, Matlab videoinput object.
            % - event, Matlab event structure.
            % - device, object implementing CamInterface.
            % - frame_count, number of frames to use.
            
            assert(event.Type=="FramesAcquired", "Incorrect event detected");
            assert(isa(device,'CamInterface'), "Device doesn't implement CamInterface");

            frame= device.acquire_frame(vidinput,frame_count);
            device.update_from_cam(frame)
            if get(vidinput,'TriggerType')=="manual"
                trigger(vidinput)
            end
            if device.stopnow()
                stop(vidinput);
                flushdata(vidinput);
            end
        end

    end

    methods (Access = protected)
        
        function launch(self, id, adaptor, format)
            % Launches videoinput object.
            %
            % Parameters
            % - id, integer device id corresponding to the camera.
            % - adaptor, string giving the name of the Matlab device driver to use.
            % - format, string giving the name of the imaging format to
            %   use.

            ID= 1;
            if isinteger(id)
               if id>0
                  ID= id;
                end
            end
             
            if ~isstring(adaptor)
                adaptor= "winvideo";
            end
            if ~isstring(format)
                format= [];
            end
            
            if isempty(format)
                device_info = imaqhwinfo(adaptor, ID);
                format = device_info.DefaultFormat;
            end
            self.device= videoinput(adaptor,ID,format);
            set(self.device,'ReturnedColorspace','grayscale');
        end

    end

    methods

        function self = Cam(id, varargin)
              % Initialize camera object.
              %
              % Parameters
              % - id, integer id of the camera device
              %
              % Optional named parameters:
              %   - 'adapter' string -- the name of the Matlab device driver to use.
              %   Def"ault: `winvideo`
              %   - 'format' string -- the name of the image format to use.
              %   When left as [] the device default format is used.
              %   Default: `[]`
              %   - 'timeout' float -- max time to wait for an image from
              %   the camera (in seconds).
              %   Default: `10`
              %   - 'colorspace' string -- colorspace of image, camera must
              %   support it.
              %   Default: `grayscale`

              p = inputParser;
              p.addParameter('adaptor', "winvideo");
              p.addParameter('format', []);
              p.addParameter('timeout', 10);
              p.parse(varargin{:});
              
              self.launch(id,p.Results.adaptor,p.Results.format);
              self.continuous_logging();
        
              if isfloat(p.Results.timeout)
                  if p.Results.timeout>0
                      set(self.device,'Timeout',p.Results.timeout);
                  end
              end
        end

        function delete(self)
          % Delete method to ensure the camera is closed on exit
          %
          delete(self.device);
          clear self.device;
        end

        function sz = size(self)
          % Gives the resolution of the camera in pixels.
          %
          width = imaqhwinfo(self.device, 'MaxWidth');
          height = imaqhwinfo(self.device, 'MaxHeight');
          sz = [height, width];
        end
        
        function setroi(self, xoffset, yoffset, width, height) 
            % Sets the region of interest of the camera.
            %
            % Parameters
            % - xoffset, horizontal offset from upper righthand corner in
            % pixels.
            % - yoffset, vertical offset from upper righthand corner in
            % pixels.
            % - width, length along x-axis of ROI in pixels.
            % - height, length along y-axis of ROI in pixels.
            
            sz= self.size();
            assert(xoffset>=0 && yoffset>=0, 'Offsets must be greater than 0.');
            assert(width<=sz(2)-xoffset && height<=sz(1)-yoffset, ... 
                'Width and height must be less than the camera size minus the given offsets.');
            
            self.device.ROIPosition = [xoffset yoffset width height];
        end
            
        function continuous_logging(self)
            % Run this function to configure camera to continously take
            % images after being triggered once.
            
            triggerconfig(self.device,'immediate');
            self.device.TriggerRepeat= 0;
            self.device.FramesPerTrigger = Inf;
        end

        function manual_logging(self, nframes)
            % Run this function to configure camera to take n images after
            % a manual trigger.
            %
            % Parameters
            % - nframes, integer number of frames to capture.
            
            triggerconfig(self.device,'manual')
            self.device.TriggerRepeat= Inf;
            self.device.FramesPerTrigger = nframes;
        end
        
        function configure(self, varargin)
           % Configures the camera.
           %
           % Optional named parameters:
           %   - 'Exposure' float -- Camera exposure. Is a negative number,
           %     x, for which the exposure time in secs is calculated as 2^x.
           %     Default: `-7`
           %   - 'Gain' float -- Camera gain. Default: `0`
           %   - 'Gamma' float -- Camera gamma. Default: `100`
           %   - 'Contrast' float -- Camera contrast. Default: `100`
           %   - 'Brightness' float -- Camera brightness. Default: `255`
           %   - 'Sharpness' float -- Camera sharpness. Default: `0`

           p = inputParser;
           p.addParameter('Exposure', -7);  
           p.addParameter('Gain', 0);
           p.addParameter('Gamma', 100); 
           p.addParameter('Contrast', 100);
           p.addParameter('Brightness', 0);
           p.addParameter('Sharpness', 0);
           p.parse(varargin{:});

           src= getselectedsource(self.device);
           vals= get(src);
           fields= fieldnames(p.Results);

           if isfield(vals, 'ExposureMode')
              src.ExposureMode= 'manual';
           end
           if isfield(vals, 'ContrastMode')
              src.ContrastMode= 'manual';
           end
           if isfield(vals, 'GainMode')
              src.GainMode= 'manual';
           end

           for i=1:numel(fields)
            if isfield(vals, fields{i})
                val= getfield(p.Results,fields{i});
                set(src, fields{i}, val);
            end
           end
           
        end

        function link_device(self, device, nframes)
            % Sets a function operating on another device 
            % to run after a certain number of frames.
            %
            % Parameters
            % - device, an object implementing CamInterface.
            % - nframes, integer number of frames to collect before executing the function.
            
            assert(isnumeric(nframes) && nframes>0);
            self.device.FramesAcquiredFcnCount= nframes;
            if get(self.device,'TriggerType')=="manual"
                self.device.FramesPerTrigger= nframes;
            end

            fcn= @(vidinput, event) Cam.framefcn(vidinput,event,device,nframes);
            self.device.FramesAcquiredFcn= fcn;
        end

        function pic = capture(self, varargin)
            % Captures an image from the camera.
            %
            % Optional named parameters:
            %   - 'flip' bool -- Whether to flip the image taken. Useful if
            %     the optics have inverted what is being imaged.
            %     Default: `false`

            p = inputParser;
            p.addParameter('flip', false);
            p.parse(varargin{:});
            
            wait(self.device);
            pic= getsnapshot(self.device); 
            
            if p.Results.flip
               pic= flip(pic,1);
            end
        end
        
        function preview(self)
            % Running this function launches a preview window. Pressing
            % any key will end the preview and resume code execution.

            preview(self.device)
            disp("Press a Key to End Preview");
            pause;
            stoppreview(self.device)
        end
        
        function start(self, varargin)
            % Starts a recording to a given file & memory if desired.
            %
            % Optional named parameters:
            %   - 'file' char -- file to save the video to. If not a char
            %     frames are logged to memory buffer.
            %     Defaults : `[]`
            %   - 'path' char -- Folder to save video to.
            %     Default: `pwd`
            %   - 'frame_rate' float -- Frame rate to display the video at.
            %     Default: `1`

            p = inputParser;
            p.addParameter('file', []);
            p.addParameter('path', pwd);
            p.addParameter('frame_rate', 1);
            p.parse(varargin{:});

            if self.device.Logging == "off"
                if ischar(p.Results.file)
                    disp("Recording to file:");
                    self.device.LoggingMode = 'disk';
                    file= fullfile(p.Results.path,p.Results.file);
                    
                    logger= VideoWriter(file);
                    logger.FrameRate= p.Results.frame_rate;
                    self.device.DiskLogger= logger;
                else
                   disp("Recording to memory:");
                   self.device.LoggingMode = 'memory'; 
                end
                start(self.device);
                if get(self.device,'TriggerType')=="manual"
                    trigger(self.device)
                end
            end
        end
    
        function stop(self)
            % Call to stop a logging/recording.

            if self.device.Logging == "on"
                stop(self.device);
                flushdata(self.device);
            end
        end
        
    end

end