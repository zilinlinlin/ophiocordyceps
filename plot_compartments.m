%% PLOT_COMPARTMENTS  Number of people in each phase (S, E, F, D) over time.
%  One graph per phase, each comparing:
%    - single-node model (all London well-mixed)
%    - grid model starting at King's Cross
%    - grid model starting at Morden
clear; clc; close all;

p = params_default();

%% Single-node model
y0 = [p.N - p.E0; p.E0; 0; 0];
opts = odeset('RelTol', 1e-8, 'AbsTol', 1e-6);
[t1, y1] = ode45(@(t, y) sefd_rhs(t, y, p), 0:0.1:p.tmax, y0, opts);

%% Grid model, both start points
starts = {'King''s Cross', p.kings_cross;
          'Morden',        p.morden};
for s = 1:size(starts, 1)
    rc = starts{s, 2};
    E0grid = zeros(p.nr, p.nc);
    E0grid(rc(1), rc(2)) = p.E0;
    fprintf('Running grid model from %s...\n', starts{s, 1});
    res(s) = run_grid_scenario(p, E0grid); %#ok<SAGROW>
end

%% Plot: one panel per phase
phases = {'S: susceptible', 'E: exposed (infected, walking around)', ...
          'F: fruiting corpses', 'D: finished (dead, done fruiting)'};

figure('Position', [100 100 1000 700]);
for k = 1:4
    subplot(2, 2, k);
    plot(t1, y1(:, k) / 1e6, 'k--', 'LineWidth', 1.2); hold on;
    for s = 1:numel(res)
        plot(res(s).t, res(s).totals(:, k) / 1e6, 'LineWidth', 1.5);
    end
    xlabel('time (days)');
    ylabel('people (millions)');
    title(phases{k});
    grid on;
    if k == 1
        legend('single node (no geography)', ['grid: ' starts{1,1}], ...
               ['grid: ' starts{2,1}], 'Location', 'southwest');
    end
end
sgtitle(sprintf('People in each phase over time (R_0 = %.1f, river permeability %.1f)', ...
                p.R0, p.river_perm));

%% Print the peaks
fprintf('\n%-28s %16s %16s\n', '', 'peak E (day)', 'peak F (day)');
[mE, iE] = max(y1(:, 2));  [mF, iF] = max(y1(:, 3));
fprintf('%-28s %8.0f (%5.1f) %8.0f (%5.1f)\n', 'single node', mE, t1(iE), mF, t1(iF));
for s = 1:numel(res)
    [mE, iE] = max(res(s).totals(:, 2));  [mF, iF] = max(res(s).totals(:, 3));
    fprintf('%-28s %8.0f (%5.1f) %8.0f (%5.1f)\n', ['grid: ' starts{s,1}], ...
            mE, res(s).t(iE), mF, res(s).t(iF));
end
