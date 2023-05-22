
path= pwd; % Directory to pull video from.
file= fullfile(path,"calibration.avi");
vid= VideoReader(file);

m1= 200; % Start of vertical position for a slice of pixels.
m2= 500; % End of vertical position for a slice of pixels
n1= 150; % Start of horizontal slice of pixels.
n2= 230; % End of horizontal slice of pixels.

func= fittype('a*cos(b*x+c)','dependent',{'y'},'independent',{'x'},...
    'coefficients',{'a','b','c'}); % Fit to cosine
X= transpose(linspace(n1,n2,(n2-n1)));

while hasFrame(vid)
    img = readFrame(vid);
    roi = img(m1:m2,n1:n2-1);
    Y= transpose(mean(sqrt(double(roi)/255),1));

    f = fit(X,Y,func,'StartPoint',[1,1,0]);
    params= coeffvalues(f);
    figure(2);
    plot(X,Y);
    disp(params(3));
end