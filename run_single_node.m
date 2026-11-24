%% RUN_SINGLE_NODE  Step 1: well-mixed S-E-F-D model of London, with checks.
%  Outputs: time to 50% infected, peak timings, final size,
%           conservation check, final-size theory check, plot.
clear; clc; close all;

p  = params_default();
y0 = [p.N - p.E0; p.E0; 0; 0];

opts = odeset('RelTol', 1e-8, 'AbsTol', 1e-6, ...
              'Events', @(t, y) half_infected(t, y, p));
[t, y, te] = ode45(@(t, y) sefd_rhs(t, y, p), 0:0.1:p.tmax, y0, opts);

S = y(:,1); E = y(:,2); F = y(:,3); D = y(:,4);
ever = (p.N - S) / p.N;               % ever infected = E + F + D

%% Results
[Emax, iE] = max(E);
[Fmax, iF] = max(F);
z_model  = ever(end);
R0_eff   = p.beta / (p.delta + p.removal);
z_theory = final_size_theory(R0_eff);
cons_err = max(abs(S + E + F + D - p.N));

[~, ~, wr] = wells_riley_beta(p);
fprintf('Single-node S-E-F-D model\n');
fprintf('  Wells-Riley: exposure %.2f min/day, spores clear from air in %.0f min,\n', ...
        p.exposure_min, wr.clear_time_min);
fprintf('               R0 would be %.0f if people breathed corpse air all day\n', ...
        wr.R0_full_exposure);
fprintf('  beta = %.4f, sigma = %.4f, delta = %.4f (per day), R0 = %.2f\n', ...
        p.beta, p.sigma, p.delta, R0_eff);
if isempty(te)
    fprintf('  50%% infected never reached\n');
else
    fprintf('  time to 50%% infected : %.1f days\n', te(1));
end
fprintf('  peak exposed (E)     : day %.1f (%s people)\n', t(iE), num2str(round(Emax)));
fprintf('  peak corpses (F)     : day %.1f (%s corpses)\n', t(iF), num2str(round(Fmax)));
fprintf('  final size (model)   : %.4f\n', z_model);
fprintf('  final size (theory)  : %.4f   [z = 1 - exp(-R0 z)]\n', z_theory);
fprintf('  max |S+E+F+D - N|    : %.2e people\n', cons_err);

%% Plot
figure;
plot(t, [S E F D] / p.N, 'LineWidth', 1.5); hold on;
plot(t, ever, 'k--');
if ~isempty(te)
    xline(te(1), ':', sprintf('50%% at day %.0f', te(1)));
end
xlabel('time (days)'); ylabel('fraction of London');
legend('S susceptible', 'E exposed', 'F fruiting corpses', 'D finished', ...
       'ever infected (E+F+D)', 'Location', 'east');
title(sprintf('Single-node S-E-F-D model (R_0 = %.1f)', R0_eff));
grid on;

%% Local functions
function [value, isterminal, direction] = half_infected(~, y, p)
    value = (p.N - y(1)) - 0.5 * p.N;   % crosses zero when 50% ever infected
    isterminal = 0;                     % don't stop the solver
    direction  = 1;                     % only when increasing
end

function z = final_size_theory(R0)
    if R0 <= 1
        z = 0;                          % no major outbreak
    else
        z = fzero(@(z) z - (1 - exp(-R0 * z)), [1e-6 1]);
    end
end
