
% Debugging SLM driver.
addpath('../');

c= Config.LCR2500('wl',488);

slm= SLM( c, 'f', 180);
im = otslm.simple.aperture(c.res, 40, 'shape', 'circle');

pattern = slm.compute_phasemask(im, 'alpha', 0.5, 'use_gpu', false, 'N', 10);

vid= record('small_shifts.avi','framerate',1);
cam_on= true;
if cam_on
    cam= Cam(1,'timeout',Inf);
    cam.configure('exposure',-8,'gain',0);
end

dz= 0.1;
open(vid);
l=-0.01;

for i=1:40
    noise= dz*rand(size(pattern,1),size(pattern,2));
    p= slm.combine_phases(pattern,noise);
    slm.show(p);
    pause(0.15);
    
    img= cam.capture('flip',1);
    l= l+0.0005;
    writeVideo(vid,img);
end
close(vid);
