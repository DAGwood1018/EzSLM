% Run with correct paths and number of frames to convert dataset into 
% a video.

path= "M:\MNIST\TrainImgs";
vid= VideoWriter("train915.avi");
open(vid)
for i=1:7999
    file= path + "\[" + string(i) + "].png";
    im= imread(file);
    writeVideo(vid,im);
end
close(vid);
%{
path= "E:\MNIST\TestImgs";
vid= VideoWriter("test.avi");
open(vid)
for i=1:2000
    file= path + "\[" + string(i) + "].png";
    im= imread(file);
    writeVideo(vid,im);
end
close(vid);
%}