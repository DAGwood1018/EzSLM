% Script that displays an image with different simulated scattering
% phase masks.

c= Config.LCR2500();
slm= CGH(c, 'f', 180, 'wl', 488);
im = otslm.simple.aperture(c.res, 40, 'shape', 'square');
pattern = slm.compute_phasemask(im, 'alpha', 0.5, 'use_gpu', true, 'N', 10, 'padding', 100);

cam= Cam(1);
cam.configure('exposure',-8);

scale= [2,4,5,6,7,8,10];
M= (floor(max(c.res)./scale));
vid= VideoWriter('artificial_scattering.avi');
vid.FrameRate=0.5;
open(vid);

slm.show();
pause(0.15);
img= cam.capture('flip', 1);
writeVideo(vid,im2frame(img));

for i=1:length(M)
    slm.simulate_scattering(M(i));
    slm.reset_mask();
    slm.show(pattern);
    pause(0.15);
    img= cam.capture('flip', 1);
    label= "N/M=" + string(round(max(c.res)/M(i),2));
    img= insertText(img,[100,100],label,'FontSize',32);
    
    writeVideo(vid,im2frame(img));
end
close(vid);