%% COMPARE_LOCATIONS  King's Cross vs Morden on the London grid (deterministic).
%  Same model, same parameters, same seed size - only the start cell changes.
clear; clc; close all;

p = params_default();
seeds = {'King''s Cross', p.kings_cross;
         'Morden',        p.morden};
fprintf('River permeability: %.2f\n', p.river_perm);

for s = 1:size(seeds, 1)
    rc = seeds{s, 2};
    E0grid = zeros(p.nr, p.nc);
    E0grid(rc(1), rc(2)) = p.E0;

    tic;
    res = run_grid_scenario(p, E0grid);
    res.name = seeds{s, 1};
    res.seed = rc;
    fprintf('%-13s time to 50%%: %6.1f days | final size: %.4f | conservation error: %.1e | %.0f s\n', ...
            res.name, res.time_to_50, res.final_size, res.conservation_error, toc);
    all_res(s) = res; %#ok<SAGROW>
end

save('grid_results.mat', 'p', 'all_res', '-v7.3');

%% Plot 1: ever infected over time
figure;
hold on;
for s = 1:numel(all_res)
    plot(all_res(s).t, all_res(s).ever_infected, 'LineWidth', 1.5);
end
yline(0.5, ':');
xlabel('time (days)'); ylabel('fraction of London ever infected');
legend({all_res.name}, 'Location', 'southeast'); grid on;
title('Spread from each starting point');

%% Plot 2: maps of ever-infected fraction at chosen days
days = [40 80 120 160];
figure;
for s = 1:numel(all_res)
    for d = 1:numel(days)
        idx = find(all_res(s).t >= days(d), 1);
        if isempty(idx), continue; end
        S = squeeze(all_res(s).U(idx, 1, :, :));
        ever = 1 - S ./ max(p.Ncell, 1);
        subplot(numel(all_res), numel(days), (s-1)*numel(days) + d);
        imagesc(ever, 'AlphaData', double(p.Ncell > 0)); clim([0 1]);
        axis image off; hold on;
        if isfield(p, 'river_col'), plot(p.river_col, p.river_row, 'c-'); end
        plot(all_res(s).seed(2), all_res(s).seed(1), 'r*');
        title(sprintf('%s, day %d', all_res(s).name, days(d)));
    end
end
colorbar('Position', [0.93 0.1 0.02 0.8]);

%% Plot 3: arrival day maps
figure;
for s = 1:numel(all_res)
    subplot(1, numel(all_res), s);
    imagesc(all_res(s).arrival, 'AlphaData', double(~isnan(all_res(s).arrival)));
    axis image off; colorbar; hold on;
    if isfield(p, 'river_col'), plot(p.river_col, p.river_row, 'c-'); end
    plot(all_res(s).seed(2), all_res(s).seed(1), 'r*');
    title(sprintf('%s: arrival day (1%% infected)', all_res(s).name));
end
