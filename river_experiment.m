%% RIVER_EXPERIMENT  How much does the Thames matter?
clear; clc; close all;

p = params_default();
perms = [1 0.2 0.05 0];
names = {'King''s Cross', 'Morden'};
cells = {p.kings_cross, p.morden};

t50 = nan(numel(perms), 2);  fs = nan(numel(perms), 2);
for k = 1:numel(perms)
    p.river_perm = perms(k);
    for s = 1:2
        E0grid = zeros(p.nr, p.nc);
        E0grid(cells{s}(1), cells{s}(2)) = p.E0;
        res = run_grid_scenario(p, E0grid);
        t50(k, s) = res.time_to_50;
        fs(k, s)  = res.final_size;
    end
    fprintf('river %.2f | KX: 50%% at %6.1f d, final %.3f | Morden: 50%% at %6.1f d, final %.3f\n', ...
            perms(k), t50(k,1), fs(k,1), t50(k,2), fs(k,2));
end

figure;
subplot(1,2,1); plot(perms, t50, 'o-'); xlabel('river permeability');
ylabel('time to 50% (days)'); legend(names); grid on;
subplot(1,2,2); plot(perms, fs, 'o-'); xlabel('river permeability');
ylabel('final size'); legend(names); grid on;
