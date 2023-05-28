% Given the MNIST dataset contained in mnist.mat, this script precomputes
% a subset of phase masks to use repeatedly for imaging.

mnist= load("mnist.mat");
path= "M:\MNIST\"; 

c= Config.LCR2500('wl', 473);
slm= SLM( c, 'f', 200);

setpath= path + "Test\mnist_test_labels.csv";
writematrix(mnist.test.labels,setpath);
setpath= path + "Train\mnist_train_labels.csv";
writematrix(mnist.training.labels,setpath);

for i=1:mnist.training.count
    input= kron(mnist.training.images(:,:,i),ones(10));
    pattern= slm.compute_phasemask(input,'alpha',0.5,'use_gpu',true,'N',10);
    filename= path + "Train\[" + string(i) + "].dat";
    writematrix(single(pattern),filename);
end

for i=1:mnist.test.count
    input= kron(mnist.test.images(:,:,i),ones(10));
    pattern= slm.compute_phasemask(input,'alpha',0.5,'use_gpu',true,'N',10);
    filename= path + "Test\[" + string(i) + "].dat";
    writematrix(single(pattern),filename);
end

