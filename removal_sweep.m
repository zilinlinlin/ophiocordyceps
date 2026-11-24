%% REMOVAL_SWEEP  Step 2: how fast must corpses be removed to stop the outbreak?
%  Sweeps the corpse removal rate and records final size and time to 50%.
%  Effective R0 = beta / (delta + removal), so the outbreak stops when
%  removal > beta - delta.
clear; clc; close all;

p  = params_default();
y0 = [p.N - p.E0; p.E0; 0; 0];

rates    = linspace(0, 0.3, 61);   % removal rate (per day)
z_model  = zeros(size(rates));
z_theory = zeros(size(rates));
t50      = nan(size(rates));

for k = 1:numel(rates)
    p.removal = rates(k);
    opts = odeset('RelTol', 1e-8, 'AbsTol', 1e-6, ...
                  'Events', @(t, y) half_infected(t, y, p));
    [~, y, te] = ode45(@(t, y) sefd_rhs(t, y, p), [0 3*p.tmax], y0, opts);

    z_model(k)  = (p.N - y(end,1)) / p.N;
    z_theory(k) = final_size_theory(p.beta / (p.delta + p.removal));
    if ~isempty(te), t50(k) = te(1); end
end

threshold = p.beta - p.delta;      % removal rate where effective R0 = 1
fprintf('Outbreak stops when removal rate > %.3f per day\n', threshold);
fprintf('  i.e. corpses removed within %.1f days on average\n', 1/threshold);

%% Plot
figure;
subplot(2,1,1);
plot(rates, z_model, 'o-', rates, z_theory, 'k--'); hold on;
xline(threshold, ':', 'R_0 = 1');
ylabel('final size (fraction infected)');
legend('model', 'theory: z = 1 - e^{-R_0 z}');
title('Effect of corpse removal'); grid on;

subplot(2,1,2);
plot(rates, t50, 'o-'); hold on;
xline(threshold, ':', 'R_0 = 1');
xlabel('corpse removal rate (per day)');
ylabel('time to 50% infected (days)'); grid on;

%% Local functions
function [value, isterminal, direction] = half_infected(~, y, p)
    value = (p.N - y(1)) - 0.5 * p.N;
    isterminal = 0;
    direction  = 1;
end

function z = final_size_theory(R0)
    if R0 <= 1
        z = 0;
    else
        z = fzero(@(z) z - (1 - exp(-R0 * z)), [1e-6 1]);
    end
end
