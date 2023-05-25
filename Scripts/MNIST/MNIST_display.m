% Given the correct paths, run to load precomputed phase masks and then
% display and image the results.

% ~5 seconds an image.
c= Config.LCR2500('wl', 473);
slm= SLM(c, 'f', 200);
Ntrain=5000;
Ntest=2000;
cam_on= true;

if cam_on
    cam= Cam(1,'timeout',Inf);
    cam.configure('exposure',-10,'gain',0);
    
    slm.show(zeros(c.res));
    file= "E:\MNIST\unmodulated_bckgrnd.png";
    bgrnd= cam.capture('flip', 1);
    imwrite(bgrnd,file);
end

t= tic();

path= "E:\MNIST\Train";
save= "M:\MNIST\TrainImgs";

disp("Collecting Training Data")
for i=1:Ntrain
    setpath= path + "\[" + string(i) + "].dat";
    pattern= readmatrix(setpath);
    slm.show(pattern);

    if cam_on
        img= cam.capture('flip', 1);
        file= save + "\[" + string(i) + "].png";
        imwrite((img),file);
    end
    
    if mod(i,100)==0
        disp("Ntrain=" + string(i))
    end
end

clear trainset

path= "E:\MNIST\Test";
save= "M:\MNIST\TestImgs";

disp("Collecting Testing Data")
for i=1:Ntrain
    setpath= path + "\[" + string(i) + "].dat";
    pattern= readmatrix(setpath);
    slm.show(pattern);
    
    if cam_on
        img= cam.capture('flip', 1);
        file= save + "\[" + string(i) + "].png";
        imwrite((img),file);
    end

    if mod(i,100)==0
        disp("Ntest=" + string(i))
    end
end

disp(toc(t));