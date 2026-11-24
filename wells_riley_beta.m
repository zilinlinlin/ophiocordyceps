function [beta, R0, info] = wells_riley_beta(p)
% WELLS_RILEY_BETA  Transmission rate beta from Wells-Riley physics.
%   Based on Edwards et al. (2024), "The Wells-Riley model revisited",
%   Risk Analysis, eqs 1-4.
%
%   Spores from fruiting corpses mix into the air shared by the people in a
%   cell. At steady state the spore concentration is
%       C = q * F / (N * R_pp)          [quanta per m^3]
%   where R_pp is the air "cleaned" per person per day (ventilation plus
%   spores settling or dying). A susceptible breathing this air for a
%   fraction f of the day is infected at rate f * p_breath * C, so
%       dS/dt = -f * p_breath * q / R_pp * S * F / N  =  -beta * S * F / N
%
%   Spores clear from the air in under an hour (vol_pp / R_pp), so on a
%   timescale of days the steady state applies and no extra spore variable
%   is needed.

    R_pp = p.vent_pp + p.vol_pp * (p.r_inact + p.r_dep);   % m^3/day per person
    f    = p.exposure_min / 1440;                          % fraction of the day

    beta = f * p.breath * p.q / R_pp;                      % per day
    R0   = beta / p.delta;

    info.R_pp           = R_pp;
    info.clear_time_min = p.vol_pp / R_pp * 1440;          % spore lifetime in air
    info.R0_full_exposure = p.breath * p.q / R_pp / p.delta;   % if f = 1
end
