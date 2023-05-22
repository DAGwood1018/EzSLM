a= 0.2;
b= 0.1;
tau= 17;
x0= 0.5;
N=12000;
dt= 0.1;

[t,x]= mackey_glass.solve_mackey_glass(x0,tau,dt,N,'a',a,'b',b,'n',10);

x= x(500:end);
t= t(500:end);
x = (x-min(x))/(max(x)-min(x));

figure
plot(t, x);
xlabel('t');
ylabel('x(t)');
title(sprintf('A Mackey-Glass time series (tau=%d)', tau));

data= struct();
disp(size(x));
data.t= t;
data.x= x;
disp(pwd);
file= fullfile(pwd,"mackey_glass.mat");
save(file,"data");