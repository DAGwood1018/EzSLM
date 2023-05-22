function phases = parallel_gerchberg_saxton(incident, targets, alpha, N, M)
    % Performs Gerchberg-Saxon algorithm.
    %
    % Parameters
    % - incident, 2D matrix (can be gpuArray) giving incident
    %   intensity.
    % - targets, 2D matrices (can be gpuArrays) in a cell array for which phase masks
    %   will be calculated.
    % - alpha, adaptive additive factor. 1 results in standard
    %   GS algorithm.
    % - N, integer number of iteratons to perform.
    % - M, max number of workers

    assert(iscell(targets), "Targets should be stored in a cell array.");
    phases= cell(size(targets,2));
    parfor (i= 1:size(targets,2), M)
        phases{i}= gerchberg_saxton(incident,targets{i},alpha,N); 
    end
end