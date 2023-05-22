classdef DisplayToScreen < handle

    properties
        screen;
        screensize;
        h;
    end

    methods (Abstract, Access=public)
        show(self)
    end

    methods (Access = protected)

        function show_img(self, pattern)
            figure(self.h);
            imshow(pattern);
        end
        
        function play_vid(self, video, fps)
            figure(self.h);
            movie(video,1,fps);
        end
            
    end

    methods

        function self = DisplayToScreen(screen)
            self.screen= screen;
            name= "DisplayToScreen#" + string(screen);
            windows= findobj('Type','figure','Name',name);
            close(windows);
            
            self.h= figure('Name',name,'WindowState', 'fullscreen', ...
                               'MenuBar', 'none', ...
                               'ToolBar', 'none');
            set(gca,'DataAspectRatioMode','auto');
            pos= get(0,'MonitorPositions'); 
            set(self.h,'Position',pos(screen,:));
            sz= [pos(screen,4),pos(screen,3)];
            self.screensize= sz;
            self.clear();
        end

        function clear(self)
            % Displays a blank screen.
            %
            imshow(zeros(self.screensize));
        end

    end
    
end