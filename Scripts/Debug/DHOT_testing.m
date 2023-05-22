% Debugging SLM driver.

addpath('../');

c= Config.LCR2500('wl',473);
slm= DHOT( c, 'f', 200 );
im = otslm.simple.aperture(c.res, 40, 'shape', 'square');
sqr = slm.compute_phasemask(im, 'alpha', 0.5, 'use_gpu', false, 'N', 10);

slm.add([0.0,0.0],sqr,0);
%slm.add_vortex([-0.01,0.0],8,0);
phase= slm.compute_tweezers('alpha',0.5, 'use_gpu', false, 'N', 10);
slm.show(phase);
