% Given the MNIST dataset contained in mnist.mat, this script precomputes
% a subset of phase masks to use repeatedly for imaging.

mnist= load("mnist.mat");
path= "M:\MNIST\"; 

c= Config.LCR2500('wl', 473);
slm= SLM( c, 'f', 200);

ID= 5;
scaling= 10;
input= kron(mnist.training.images(:,:,ID),ones(scaling));
pattern= slm.compute_phasemask(input,'alpha',0.5,'use_gpu',true,'N',10);
slm.show(pattern);

