% Run optical reservoir class with Mackey-Glass data

% Create a configuration and start camera
c= Config.LCR2500('wl',473,'focal_length',300);
cam= Cam(1,'timeout',Inf);
cam.configure('exposure',-8,'gain',0);
cam.manual_logging(3); % It is better to use repeated triggers rather than continuous imaging.

% Get Mackey-Glass time series
a= 0.2;
b= 0.1;
tau= 17;
x0= 0.5;
N=12000;
dt= 0.1;
[t,x]= mackey_glass.solve_mackey_glass(x0,tau,dt,N,'a',a,'b',b,'n',10);

% Discard initial time series values and normalize to be between 0 & 1
x= x(500:end);
t= t(500:end);
x = (x-min(x))/(max(x)-min(x));

% Create optical reservoir object
res=OptReservoir(c,'sz',[256,256],'spacing',4,'f',200,'dt',0);

% Initialize reservoir with time series
res.initialize(x);

% Link camera for imaging and start it to execute reservoir
cam.link_device(res,3);
cam.start();
