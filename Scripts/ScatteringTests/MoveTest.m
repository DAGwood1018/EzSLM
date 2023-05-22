
r=40;
shape= 'circle';
addpath('../');
c= Config.LCR2500('wl',488);
slm= SLM( c, 'f', 180);

startpoint= [0.25, 0.25];
endpoint= [-0.25, -0.25];
startpoint(1) = floor(0.5*(c.res(1)+1)*startpoint(1)+c.res(1)/2); 
startpoint(2) = floor(0.5*(c.res(2)+1)*startpoint(2)+c.res(2)/2);
endpoint(1) = floor(0.5*(c.res(1)+1)*endpoint(1)+c.res(1)/2); 
endpoint(2) = floor(0.5*(c.res(2)+1)*endpoint(2)+c.res(2)/2);
Nsteps=20;
stdev=2;

dx= randn(1,Nsteps-1)*stdev;
dy= randn(1,Nsteps-1)*stdev;
dx= dx - mean(dx);
dy= dy - mean(dy);

cam_on= true;
if cam_on
    cam= Cam(1,'timeout',Inf);
    cam.configure('exposure',-8,'gain',0);
    
    slm.show_null();
    pause(0.15);
    file= "move_bckgrnd.png";
    bgrnd= cam.capture('flip', 1);
    imwrite(bgrnd,file);
end

% Generate path
path= cell(1, Nsteps);
ystep= dy + (endpoint(1)-startpoint(1))/(Nsteps-1);
xstep= dx + (endpoint(2)-startpoint(2))/(Nsteps-1);
Y= startpoint(1);
X= startpoint(2);
for i=1:Nsteps-1
    input= otslm.simple.aperture(c.res, r, 'shape', shape, 'centre', [X, Y]);
    pattern= slm.compute_phasemask(input, 'alpha', 0.5, 'use_gpu', true, 'N', 10);
    path{i}= pattern;
    X= X+xstep(i);
    Y= Y+ystep(i);
end
input= otslm.simple.aperture(c.res, r, 'shape', 'square', 'centre', [endpoint(2), endpoint(1)]);
pattern= slm.compute_phasemask(input, 'alpha', 0.5, 'use_gpu', true, 'N', 10);
path{Nsteps}= pattern;

if cam_on
   cam.start('move_test.avi','frame_rate',2);
end
slm.play(path,'fps',1);

if cam_on
    cam.stop();
end
