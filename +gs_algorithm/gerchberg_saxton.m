function phase = gerchberg_saxton(incident, target, alpha, N)
    % Performs Gerchberg-Saxon algorithm.
    %
    % Parameters
    % - incident, 2D matrix (can be gpuArray) giving incident
    %   intensity.
    % - target, 2D matrix (can be gpuArray) for which phase mask
    %   will be calculated.
    % - alpha, adaptive additive factor. 1 results in standard
    %   GS algorithm.
    % - N, integer number of iteratons to perform.

    assert(isequal(size(incident),size(target)), 'Incident and Target must have same dimensions.')
    assert(length(size(incident))==2, 'Incident and Target must be 2 dimensional.')
    if isa(target, 'gpuArray')
       if ~isa(incident, 'gpuArray')
            incident= gpuArray(incident);
       end
    elseif isa(incident, 'gpuArray')
        if ~isa(target, 'gpuArray')
            target= gpuArray(target);
        end
    end 

    target=double(target);
    A = (ifft2(fftshift(target))).*numel(target);
    for i=1:N
        B = abs(incident) .* exp(1i*angle(A));
        C = fftshift(fft2((B)))./numel(B);
        
        T= alpha.*abs(target) ...
            + (1 - alpha).*abs(C);
        
        D = T .* exp(1i*angle(C));
        A = (ifft2(fftshift(D))).*numel(D);
    end
    
    if isa(A, 'gpuArray')
        A= gather(A);
    end

    phase= angle(A)+pi;
end