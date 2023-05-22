function Z = aberration(sz, varargin)
    % Calculates an aberration using Zernike polynomials.
    %
    % Parameters
    % - sz, Dimensions of 2D matrix.
    %
    % Optional named parameters:
    %  - 'piston', vtilt, htilt, obl_astimatism', 'defocus', 'astigmatism',
    %    'vtrefoil', 'vcoma', 'hcoma', 'obl_trefoil', 
    %
    % See https://en.wikipedia.org/wiki/Zernike_polynomials for more info

    p = inputParser;
    p.addParameter('piston', 0); % m=n=0
    p.addParameter('vtilt', 0); % m=-n=-1
    p.addParameter('htilt', 0); % m=n=1
    p.addParameter('obl_astigmatism', 0); % m=-n=-2
    p.addParameter('defocus', 0); % m=0,n=2
    p.addParameter('astigmatism', 0); % m=n=2
    p.addParameter('vtrefoil', 0); % m=-n=-3
    p.addParameter('vcoma', 0); % m=-1,n=3
    p.addParameter('hcoma', 0); % m=1,n=3
    p.addParameter('obl_trefoil', 0); % m=n=3
    p.addParameter('obl_quadrafoil', 0); %m=-n=-4
    p.addParameter('obl_astigmatism2', 0); % m=-2,n=4
    p.addParameter('spherical', 0); % m=0,n=4
    p.addParameter('astigmatism2', 0); % m
    p.addParameter('vquadrafoil', 0);
    p.parse(varargin{:});

    Z = zeros(sz);
    if p.Results.piston~=0
        m=0; n=0;
        Z= Z + p.Results.piston*otslm.simple.zernike(sz,m,n);
    end
    if p.Results.vtilt~=0
        m=-1; n=1;
        Z= Z + p.Results.vtilt*otslm.simple.zernike(sz,m,n);
    end
    if p.Results.htilt~=0
        m=1; n=1;
        Z= Z + p.Results.htilt*otslm.simple.zernike(sz,m,n);
    end
    if p.Results.obl_astigmatism~=0
        m=-2; n=2;
        Z= Z + p.Results.obl_astigmatism*otslm.simple.zernike(sz,m,n);
    end
    if p.Results.defocus~=0
        m=0; n=2;
        Z= Z + p.Results.defocus*otslm.simple.zernike(sz,m,n);
    end
    if p.Results.astigmatism~=0
        m=2; n=2;
        Z= Z + p.Results.astigmatism*otslm.simple.zernike(sz,m,n);
    end
    if p.Results.vtrefoil
        m=-3; n=3;
        Z= Z + p.Results.vtrefoil*otslm.simple.zernike(sz,m,n);
    end
    if p.Results.vcoma
        m=-1; n=3;
        Z= Z + p.Results.vcoma*otslm.simple.zernike(sz,m,n);
    end
    if p.Results.hcoma
        m=1; n=3;
        Z= Z + p.Results.hcoma*otslm.simple.zernike(sz,m,n);
    end
    if p.Results.obl_trefoil~=0
        m=3; n=3;
        Z= Z + p.Results.obl_trefoil*otslm.simple.zernike(sz,m,n);
    end
    if p.Results.obl_quadrafoil
        m=-4; n=4;
        Z= Z + p.Results.obl_quadrafoil*otslm.simple.zernike(sz,m,n);
    end
    if p.Results.obl_astigmatism2~=0
        m=-2; n=4;
        Z= Z + p.Results.obl_astigmatism2*otslm.simple.zernike(sz,m,n);
    end
    if p.Results.spherical~=0
        m=0; n=4;
        Z= Z + p.Results.spherical*otslm.simple.zernike(sz,m,n);
    end
    if p.Results.astigmatism2~=0
        m=2; n=4;
        Z= Z + p.Results.astigmatism2*otslm.simple.zernike(sz,m,n);
    end
    if p.Results.vquadrafoil~=0
        m=4; n=4;
        Z= Z + p.Results.vquadrafoil*otslm.simple.zernike(sz,m,n);
    end
end