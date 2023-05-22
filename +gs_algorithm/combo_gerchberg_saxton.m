function phase = combo_gerchberg_saxton(components, alpha, N)
    % Performs Gerchberg-Saxon algorithm to combine multiple phase
    % phase masks.
    %
    % Parameters
    % - components, 3D array of phase masks to combine (first two axes give mask dims).
    % - alpha, adaptive additive factor. 1 corresponds to normal GS
    %   algorithm.
    % - N, number of iterations to perform.

    nn= size(components,3);
    epsilon = zeros(nn,N,'single');
    A = zeros(nn,N,'single');
    A(:, 1) = ones(nn, 1)/sqrt(nn); % epsilon_j = alpha_j * exp(i* phi_j)
    epsilon(:,1) = A(:, 1);
    
    if isa(components, 'gpuArray')
        A= gpuArray(A);
        epsilon= gpuArray(epsilon);
    end
    
    e= exp(1i*components);
    E = sum(bsxfun(@times,e,reshape(epsilon(:,1),1,1,nn)),3); % Eq. (1) of the dhot paper
    dA= size(components,1)*size(components,2);
    
    for i = 1:N % iterations in the GS algorithm, Eq. (3) of the dhot paper
        % Compute phi^{(n)} from equation (2) and E.
        phi_sum = (E./abs(E))./e;  
        % Compute next epsilon values using equation (3) and phi.
        epsilon(:, i) = reshape(sum(sum(phi_sum,1),2),[1,nn])/dA;
        % Replace amplitudes using equation (4).
        A(:, i) = abs(epsilon(:, i));
        A_prime = (1 - alpha)*A(:, 1) + alpha*A(:,1).^2./A(:, i);
        epsilon(:,i) = A_prime.*exp(1i*angle(epsilon(:,i)));
        % Compute E from equation (1) which is the early form of the phase mask
        E = sum(bsxfun(@times,e,reshape(epsilon(:,i),1,1,nn)),3); 
    end

    if isa(E, 'gpuArray')
        E= gather(E);
    end
    phase = angle(E) + pi;  
  end 