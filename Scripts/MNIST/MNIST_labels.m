% Extracts a subset of labels from the MNIST dataset contained in
% mnist.mat

mnist= load("mnist/mnist.mat");
path= "E:\MNIST\";

N=8000;
M=2000;
setpath= path + "Test\mnist_test_labels.csv";
writematrix(mnist.test.labels(1:M),setpath);
setpath= path + "Train\mnist_train_labels.csv";
writematrix(mnist.training.labels(1:N),setpath);