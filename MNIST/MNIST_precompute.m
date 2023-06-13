% Given the MNIST dataset contained in mnist.mat, this script precomputes
% a subset of phase masks to use repeatedly for imaging.

mnist= load("mnist.mat");
path= "M:\MNIST\ScaledSet\";

c= Config.LCR2500('wl', 473);
slm= SLM( c, 'f', 200);


%setpath= path + "Test\mnist_test_labels.csv";
%writematrix(mnist.test.labels,setpath);
%setpath= path + "Train\mnist_train_labels.csv";
%writematrix(mnist.training.labels,setpath);

Ntrain=8000;
Ntest=2000;

for j=3:26
    for i=3:Ntrain
        input= kron(mnist.training.images(:,:,i),ones(j));
        pattern= slm.compute_phasemask(input,'alpha',0.5,'use_gpu',true,'N',10);
        filename= path + "Train\[" + string(i) + "]_x" + string(j) + ".dat";
        writematrix(single(pattern),filename);
    end
    
    for i=3:Ntest
        input= kron(mnist.test.images(:,:,i),ones(j));
        pattern= slm.compute_phasemask(input,'alpha',0.5,'use_gpu',true,'N',10);
        filename= path + "Test\[" + string(i) + "]_x" + string(j) + ".dat";
        writematrix(single(pattern),filename);
    end
end

