
config = Config.Multiscale('focal_length', 1);
slm = SLM(config, 'f', 200);

pos= [[0.25,0.25];[0.75,0.75];[0.25,0.75];[0.75, 0.25]];
circle_tweezer = otslm.simple.aperture(config.res,25,'shape','circle');
phase = slm.compute_phasemask(pattern,'use_gpu',true,'alpha',0.5);
slm.add(pos,phase,0);

tweezer_array = slm.compute_tweezers('use_gpu',true,'alpha',0.5);

pause(5)
for i=1:15
    slm.show(tweezer_array);
    pause(2);
    slm.show_null();
    pause(2);
end