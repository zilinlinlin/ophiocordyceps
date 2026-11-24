%% WAVE_SPEED_CHECK  Validation: measured front speed vs theory.
%  Uses a plain uniform 40 x 40 grid (no London shape, no river) and seeds
%  the whole top row, so a flat front travels south. Measures its speed from
%  arrival times and compares with wave_speed_theory.
clear; clc; close all;

p = params_default();
p.Ncell  = 5000 * ones(40);   p.open   = true(40);
p.riverV = false(39, 40);     p.riverH = false(40, 39);
[p.nr, p.nc] = size(p.Ncell);

E0grid = zeros(p.nr, p.nc);
E0grid(1, :) = p.E0;                    % flat line of seeds along the north edge
res = run_grid_scenario(p, E0grid);

col  = round(p.nc / 2);                 % look down the middle column
dist = ((1:p.nr)' - 1) * p.dx;          % km from the seeded row
arr  = res.arrival(:, col);
use  = dist >= 5 & dist <= 35 & ~isnan(arr);

fit = polyfit(dist(use), arr(use), 1);  % arrival = dist/c + const
c_measured = 1 / fit(1);
c_theory   = wave_speed_theory(p);

fprintf('Front speed measured : %.3f km/day\n', c_measured);
fprintf('Front speed theory   : %.3f km/day\n', c_theory);
fprintf('Relative difference  : %.1f %%\n', 100 * abs(c_measured - c_theory) / c_theory);

figure;
plot(dist(use), arr(use), 'o', dist(use), polyval(fit, dist(use)), '-');
xlabel('distance from seeded row (km)'); ylabel('arrival day');
title(sprintf('Front speed: measured %.3f vs theory %.3f km/day', c_measured, c_theory));
grid on;
