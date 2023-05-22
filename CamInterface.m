classdef (Abstract) CamInterface < handle
    % If a class implements these methods it can be used by the link_device
    % function of the Cam class.

    methods (Access= public, Abstract)

        % must acquire and process frame(s) from vidinput and then
        % return a single processed frame as output.
        frame = acquire_frame(self, vidinput, frame_count)

        % should update the device based on the acquired frame.
        update_from_cam(self, frame)

        % condition for ending frame acquisition.
        stop = stopnow(self)
        
    end

end