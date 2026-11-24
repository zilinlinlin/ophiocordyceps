function c = wave_speed_theory(p)
    s = @(lam) max(real(eig([-p.sigma + p.DE*lam^2,  p.beta;
                              p.sigma,               -(p.delta + p.removal)])));
    [~, c] = fminbnd(@(lam) s(lam) / lam, 1e-3, 10);
end
