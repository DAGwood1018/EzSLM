N=1001;
train= false;
if train
    path= "M:\MNIST\Train";
else
    path= "M:\MNIST\Test";
end

c= Config.LCR2500('wl',473);
cam= Cam(1,'timeout',Inf);
cam.configure('exposure',-10,'gain',0);
cam.manual_logging(1);

%{
disp("Collecting Phases")
dataset2= cell(N);
for i=1:N
    setpath= path + "\[" + string(i) + "].dat";
    pattern= readmatrix(setpath);
    dataset2{i}= pattern;
end
disp("Collected Patterns")
pause;
%}

vid= VideoWriter('test','Archival');
slm= RecordableSLM(c,'f',200,'dt',0.15);
slm.initialize(dataset2,vid);

cam.link_device(slm,1);
cam.start();
