function dy = sefd_rhs(~, y, p)
% SEFD_RHS  Single-node (well-mixed) S-E-F-D equations.
%   y = [S; E; F; D]
%
%   dS/dt = -beta*S*F/N
%   dE/dt =  beta*S*F/N - sigma*E
%   dF/dt =  sigma*E - (delta + removal)*F
%   dD/dt =  (delta + removal)*F
%
%   beta comes from Wells-Riley (wells_riley_beta.m).

    S = y(1); E = y(2); F = y(3);

    infection = p.beta * S * F / p.N;       % only corpses (F) infect
    leave_F   = (p.delta + p.removal) * F;  % finished fruiting, or removed

    dy = [ -infection;
            infection - p.sigma*E;
            p.sigma*E - leave_F;
            leave_F ];
end
