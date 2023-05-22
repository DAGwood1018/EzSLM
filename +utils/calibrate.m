function calibrate(slm, phase_offset, grating_period)
    % Displays a phase pattern consisting of a constant phase on
    % 1/2 of the screen and a binary grating on the other. If a
    % camera is placed where the interference pattern is produced
    % the phase shift of a grayscale level can be calibrated.
    %
    % Parameter
    %  - slm, SLM object to display phase mask on.
    %  - phase_offset, integer giving the constant phase offset 
    %    for 1/2 of the screen.
    %  - grating_period, binary grating period (in pixels) to use
    %    for other 1/2 of the screen.
    %
    % See https://www.youtube.com/watch?v=3GGVmw1_8W8&t=644s
    
    res= slm.size();
    screen= slm.encode(slm.binary_grating(grating_period,0));
    screen(1:res(1),1:res(2)/2,:)= mod(phase_offset,slm.nlevels);
    slm.show(screen,'encode',false);
end