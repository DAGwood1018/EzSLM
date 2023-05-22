function yf = mackey_glass_eq(y,y_lag,varargin)
    % Mackey-Glass function

    p = inputParser;
    p.KeepUnmatched= true;
    p.addParameter('a', 1);
    p.addParameter('b', 1);
    p.addParameter('n', 10);
    p.parse(varargin{:});

    yf= zeros(1,1);
    yf(1)= p.Results.a*y_lag/(1+y_lag^p.Results.n)-p.Results.b*y;

end