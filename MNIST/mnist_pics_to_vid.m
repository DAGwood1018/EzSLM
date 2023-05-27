% Run with correct paths and number of frames to convert dataset into 
% a video.

path= "M:\MNIST\TrainImgs";
vid= VideoWriter("train.avi");
open(vid)
for i=1:8000
    file= path + "\[" + string(i) + "].png";
    im= imread(file);
    writeVideo(vid,im);
end
close(vid);

path= "M:\MNIST\TestImgs";
vid= VideoWriter("test.avi");
open(vid)
for i=1:2000
    file= path + "\[" + string(i) + "].png";
    im= imread(file);
    writeVideo(vid,im);
end
close(vid);
