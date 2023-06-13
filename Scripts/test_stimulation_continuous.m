
config = Config.Multiscale('focal_length', 150);
slm = SLM(config, 'f', 200);
rad = 0.18;
pos= [[-rad,0];[rad,0];[0,rad];[0,-rad]];
circle_tweezer = otslm.simple.aperture(config.res,50,'shape','circle');
pad = 100;
phase = slm.compute_phasemask(circle_tweezer,'use_gpu',true,'alpha',0.5, 'padding', pad);
slm.add(pos,pattern,0);
tweezer_array = slm.compute_tweezers('use_gpu',true,'alpha',0.5,'padding',pad);
slm.show(tweezer_array);


