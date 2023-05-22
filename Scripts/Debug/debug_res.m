
c= Config.LCR2500('wl',451);

cam= Cam(1,'timeout',Inf);
cam.configure('exposure',-8,'gain',0);

input= rand(12);
res=OptRes(c,'f',Inf);
res.initialize(input);
cam.link_device(res,1);

cam.start('testing_feedback.avi','buffer_frames',true);