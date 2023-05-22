% Calculates the cross correlation between input (image with no scattering)
% and output (image with scattering) and puts results in a video.

path= "C:\Users\Davis Garwood\Desktop";
file= "train.avi";
bckgrnd= "unmodulated_bckgrnd.png";
vid= VideoReader(fullfile(path,file));
new_vid= VideoWriter(fullfile(path,"example.avi"));
new_vid.FrameRate= 1/20;
%bckgrnd= (imread(fullfile(path,bckgrnd)));

open(new_vid);
for i=1:5
    input= imread(fullfile(path,string(i)+".png"));
    input= cast(input,'single')./225.0;
    frame= rgb2gray(readFrame(vid));
    frame= cast(frame,'single')./255.0;
    
    f= figure(i);
    subplot(1,3,1)
    imshow(input,'Colormap',colormap("parula"));
    title("Input")
    axis off;
    c= colorbar();
    c.Label.String= "Norm(I)";

    subplot(1,3,2)
    imshow(frame,'Colormap',colormap("parula"));
    title("Output")
    c= colorbar();
    c.Label.String= "Norm(I)";
    axis off;

    subplot(1,3,3)
    C= xcorr2(input,frame)./(numel(input)*sqrt(var(reshape(input,1,[]))*var(reshape(frame,1,[]))));
    imshow(C,'Colormap',colormap("hot"));
    title("X-Correlation of I/O")
    c= colorbar();
    c.Label.String= "Norm(X-Corr)";
    caxis([min(min(C)),max(max(C))]);
    axis off;

    new_frame= getframe(f);
    writeVideo(new_vid,new_frame);
end
close(new_vid);