
% x range: [-0.6, 0.55] or [150,850]
% y range: [-0.35, 0.3] or [200,600]

addpath('../');
c= Config.LCR2500('wl', 488);
slm= SLMv2( c, 'f', 180);

x0= -0.55;
y0= -0.25;
xmax= 0.5;
ymax= 0.3;

spacing= 0.05;
jsteps= (xmax-x0)/spacing;
isteps= (ymax-y0)/spacing;

img= otslm.simple.aperture(c.res, 20, 'shape', 'square');
pattern = slm.compute_phasemask(img, 'alpha', 0.5, 'use_gpu', false, 'N', 10);
N=0;
x=x0;
y=y0;

cam_on= false;
if cam_on
    vid= record('medium_scan.avi','framerate',5);
    open(vid);
    cam= Cam(1,'timeout',Inf);
    cam.configure('exposure',-8,'gain',0);
end

for i=1:isteps
    for j=1:jsteps
        slm.reset_mask();
        slm.apply_grating([x,y],false);
    	slm.show(pattern);

        if cam_on
            img= cam.capture('flip',1);
            writeVideo(vid,img);
        end
        x= x+spacing;
        N= N+1;
    end
    y= y+spacing;   
    x=x0;
end

if cam_on
    close(vid);
end


