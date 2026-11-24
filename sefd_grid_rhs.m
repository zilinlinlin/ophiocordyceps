function dy = sefd_grid_rhs(~, y, p)
% SEFD_GRID_RHS  S-E-F-D reaction-diffusion model on the London grid
%   (method of lines: every cell's S, E, F, D stacked into one vector).
%
%   dS/dt = -beta*S*F/Ncell
%   dE/dt =  beta*S*F/Ncell - sigma*E + DE*laplacian(E)   <- exposed people move
%   dF/dt =  sigma*E - (delta + removal)*F                 <- corpses don't move
%   dD/dt =  (delta + removal)*F
%   Movement across the Thames is scaled by p.river_perm (via p.Kv, p.Kh).

    U = reshape(y, p.nr, p.nc, 4);
    S = U(:,:,1);  E = U(:,:,2);  F = U(:,:,3);

    infection = p.beta .* S .* F ./ max(p.Ncell, 1);   % per cell
    leave_F   = (p.delta + p.removal) .* F;

    dS = -infection;
    dE =  infection - p.sigma .* E + p.DE .* laplacian_faces(E, p.Kv, p.Kh, p.dx);
    dF =  p.sigma .* E - leave_F;
    dD =  leave_F;

    dy = [dS(:); dE(:); dF(:); dD(:)];
end
