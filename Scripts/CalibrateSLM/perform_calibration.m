
% Create SLM configuration
c= Config.LCR2500('wl', 473);
slm= SLM(c, 'f', Inf);

bit_depth= 8; % Specify the bit depth of the SLM here.
grating_period= 3; % Binary grating peroid to use [in pixels]
cam_on= false;

if cam_on % Start camera
    cam= Cam(1,'timeout',Inf);
    cam.configure('exposure',-10,'gain',0);
    %cam.setroi(0,0,380,380);
end

Y= c.res(2)/2 * c.pitch; % Half the width of SLM
phi= asin(c.wl/(grating_period*c.pitch)); % Angle of 1st order diffration
disp('Camera should be at a distance of ~' + string(Y/tan(phi)) + ' [mm]');

disp("Press key to collect calibration images")
pause;

vid= VideoWriter('calibration.avi');
open(vid);

for i=1:2^bit_depth
    calibrate(slm,i-1,grating_period);
    pause(0.15);
    disp(i-1);
    if cam_on
        img= cam.capture('flip', 1);
        writeVideo(vid,img);
    end
end
close(vid);