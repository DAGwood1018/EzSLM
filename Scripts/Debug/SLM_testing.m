% Debugging SLM driver.
addpath('../');

c= Config.LCR2500('wl',473);

r= round(0.7*400/25.4/c.pitch);
I= @(sz) otslm.simple.gaussian(sz,r);

slm= SLMv2( c, 'f', 200);
im = otslm.simple.aperture(c.res, 40, 'shape', 'square');

%slm.apply_grating([-4.5,0],false);
phase= slm.compute_phasemask(im, 'incident', I, 'alpha',0.5,'use_gpu',false);
slm.show(phase);
