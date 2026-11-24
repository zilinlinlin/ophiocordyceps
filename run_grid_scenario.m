function res = run_grid_scenario(p, E0grid)
% RUN_GRID_SCENARIO  Solve the grid S-E-F-D model from a given seed.
%   p      : parameter struct (params_default)
%   E0grid : nr x nc matrix, exposed people in each cell at day 0
%   res    : results struct (agreed output format)
%     res.t                  days (column)
%     res.U                  [time, compartment, row, col]  (compartments S E F D)
%     res.totals             time x 4 totals of S E F D
%     res.time_to_50         day 50% of the population is ever infected (NaN if never)
%     res.ever_infected      fraction ever infected over time
%     res.final_size         fraction ever infected at the end
%     res.arrival            nr x nc, first day each cell reaches 1% ever infected
%     res.conservation_error max |S+E+F+D - total| (should be ~0)

    nr = p.nr;  nc = p.nc;
    p.Ncell(~p.open) = 0;                  % nobody lives outside London

    % face permeabilities: 0 next to closed cells, river_perm across the Thames
    p.Kv = double(p.open(1:end-1, :) & p.open(2:end, :));
    p.Kh = double(p.open(:, 1:end-1) & p.open(:, 2:end));
    p.Kv(p.riverV) = p.Kv(p.riverV) * p.river_perm;
    p.Kh(p.riverH) = p.Kh(p.riverH) * p.river_perm;

    S0 = p.Ncell - E0grid;
    y0 = [S0(:); E0grid(:); zeros(nr*nc, 1); zeros(nr*nc, 1)];
    Ntot = sum(p.Ncell(:));

    opts = odeset('RelTol', 1e-6, 'AbsTol', 1e-3, ...
                  'Events', @(t, y) half_event(t, y, nr*nc, Ntot));
    [t, y, te] = ode45(@(t, y) sefd_grid_rhs(t, y, p), 0:1:p.tmax, y0, opts);

    T = numel(t);
    U = reshape(y.', nr, nc, 4, T);        % (row, col, compartment, time)

    res.t      = t;
    res.U      = permute(U, [4 3 1 2]);    % (time, compartment, row, col)
    res.totals = squeeze(sum(sum(U, 1), 2)).';
    res.Ntot   = Ntot;
    res.time_to_50 = NaN;
    if ~isempty(te), res.time_to_50 = te(1); end
    res.ever_infected = (Ntot - res.totals(:,1)) / Ntot;
    res.final_size    = res.ever_infected(end);
    res.conservation_error = max(abs(sum(res.totals, 2) - Ntot));

    % arrival day: first day a cell has >= 1% of its residents ever infected
    everCell = (p.Ncell - squeeze(U(:,:,1,:))) ./ max(p.Ncell, 1);   % nr x nc x T
    res.arrival = nan(nr, nc);
    for i = 1:nr
        for j = 1:nc
            if p.Ncell(i,j) > 0
                k = find(everCell(i,j,:) >= 0.01, 1);
                if ~isempty(k), res.arrival(i,j) = t(k); end
            end
        end
    end
end

function [value, isterminal, direction] = half_event(~, y, ncells, Ntot)
    value = (Ntot - sum(y(1:ncells))) - 0.5 * Ntot;
    isterminal = 0;
    direction  = 1;
end
