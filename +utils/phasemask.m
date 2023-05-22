function phase = phasemask(N, M)
    % Returns random phase angles distributed across a square matrix
    % in real space using the procedure described in the supplemental
    % material of the article:
    %
    % "Statistical dependencies beyond linear correlations in
    % light scattered by disordered media"
    %
    % Ilya Starshynov, Alex Turpin, Philip Binner, and Daniele Faccio
    % Phys. Rev. Research 4, L022033
    % DOI: 10.1103/PhysRevResearch.4.L022033
    %
    % N = dimension of the matrix (N*N)
    %
    % M = dimension ( < N ) of central sub-matrix in k-space which
    %     is filled with random complex numbers as part of the
    %     phase angle generating process
    %
    % (1) The initial N*N matrix in k-space is filled with zeros and
    % a M*M submatrix in its center is filled with random complex
    % numbers that have a Gaussian distribution of with a mean value
    % of zero and a standard deviation of 1.
    % (2) The k-space matrix is then inverse Fourier transformed
    % (3) The phase of the resulting matrix of complex numbers is used 
    %     as a phase mask.
    %
    % Adapted from code written by:
    %    Joe Schick
    %    Department of Physics
    %    Villanova University
    %    joseph.schick@villanova.edu

    dn= floor(N/2) - floor(M/2);

    A= randn(M*M,1);
    rng shuffle;
    B= randn(M*M,1);
    rng shuffle;

    Z= complex(A,B);
    Z= Z - mean(Z);
    Z= Z/var(Z);

    Z= padarray(reshape(Z,M,M), [dn,dn], 0, 'both');
    Z= ifft2(ifftshift(Z));
    phase= (angle(Z) + pi)./(2*pi);
end