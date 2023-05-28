function [T,X] = solve_mackey_glass(x0,tau,dt,N,varargin)
    % Numerically solve the Mackey-Glass equation using 4th order
    % Runge-Kutta
    %
    % Parameters
    % x0, starting x value (between 0 and 1)
    % tau, time delay for Mackey Glass equation
    % dt, time step separation
    % N, number to time steps to compute

    MG_eq = @(x,x_lag) mackey_glass.mackey_glass_eq(x,x_lag,varargin{:});
    L= floor(tau/dt);
    history = zeros(L,1);
    
    t=1;
    X= zeros(N+1,1);
    T= zeros(N+1,1);
    X(1)= x0;
    
    for i=1:N
        x_t= X(i);
        x_lag= history(t);
        
        % 4th order Runge-Kutta
        k1 = dt*MG_eq(x_t, x_lag);
        k2 = dt*MG_eq(x_t+0.5*k1, x_lag);
        k3 = dt*MG_eq(x_t+0.5*k2, x_lag);
        k4 = dt*MG_eq(x_t+k3, x_lag);
        x_dt = (x_t + k1/6 + k2/3 + k3/3 + k4/6);
    
        history(t)= x_dt;
        t= mod(t,L)+1;
        T(i+1)= T(i)+dt;
        X(i+1)= x_dt;
    end
end