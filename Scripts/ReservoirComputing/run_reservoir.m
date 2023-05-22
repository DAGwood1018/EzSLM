c= Config.LCR2500('wl',473,'focal_length',300);

cam= Cam(1,'timeout',Inf);
cam.configure('exposure',-8,'gain',0);
cam.manual_logging(3);

input= load('C:\Users\Admin\Documents\MATLAB\EasySLM\+mackey_glass\mackey_glass.mat');

x= input.data.x(1:1200);
res=OptReservoir(c,'sz',[256,256],'spacing',4,'f',200,'dt',0);

res.initialize(x);
cam.link_device(res,3);
cam.start();
