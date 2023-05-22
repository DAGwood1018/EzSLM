
r=20;
addpath('../');
c= Config.LCR2500('wl',488);

nxm=3;
length= 0.5;

[x,y]= meshgrid(linspace(-length,length,nxm),linspace(-length,length,nxm));
grid_points= [x(:) y(:)];
N= 1:nxm^2;

cam_on= true;
if cam_on
    cam= Cam(1,'timeout',Inf);
    cam.configure('exposure',-8,'gain',0);
    
    slm.show_null();
    pause(0.15);
    file= "dot_bckgrnd.png";
    bgrnd= cam.capture('flip', 1);
    imwrite(bgrnd,file);

    vid= VideoWriter("dots.avi");
    open(vid);
end

slm= SLM(c, 'f', 180);
for k=1:4
    C= nchoosek(N,k);
    radii= zeros(k,1)+r;
    for i=1:size(C,1)
       input= slm.spots(c.res,grid_points(C(i,:),:),r);
       pattern= slm.compute_phasemask(input, 'alpha', 0.5, 'use_gpu', true, 'N', 15);
       pattern= slm.combine_phases(pattern, randn(slm.size())*.1);
       slm.show(pattern);
       pause(0.15);

       if cam_on
            img= cam.capture('flip', 1);
            writeVideo(vid,img);
       end
    end
end

if cam_on
    close(vid)
end
