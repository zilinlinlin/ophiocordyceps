    function p = params_default()
    % --- population and seeding ---
    p.N  = 9089736;     % London population, ONS mid-2024 (single-node model)
    p.E0 = 1;          % seed size: people in E at day 0

    % --- disease timings (fungus rules) ---
    p.sigma = 1/2.5;    % 1/mean incubation, E -> F   (rule: 1-4 days)
    p.delta = 1/14;     % 1/mean fruiting time, F -> D (rule: 1-3 weeks)

    % --- transmission: Wells-Riley (Edwards et al. 2024) ---
    p.breath  = 0.01 * 1440;     % breathing rate, m^3/day (0.01 m^3/min, Edwards; Noakes & Sleigh 2009)
    p.q       = 6 * 1440;        % spores (quanta) per corpse per day (6 quanta/min, Edwards' SARS-CoV-2 value)
    p.vent_pp = 10e-3 * 86400;   % ventilation per person, m^3/day (~10 L/s per person, UK guidance - CHECK)
    p.vol_pp  = 75;              % PLACEHOLDER: indoor air volume per person, m^3 (~30 m^2 x 2.4 m)
    p.r_inact = 0.00525 * 1440;  % spore inactivation rate, per day (Edwards midpoint, Miller et al. 2021)
    p.r_dep   = 0.015 * 1440;    % spore deposition rate, per day (Edwards midpoint, Miller et al. 2021)
    p.exposure_min = 7.05;       % minutes per day a person breathes a corpse's air

    [p.beta, p.R0] = wells_riley_beta(p);

    % --- intervention ---
    p.removal = 0;      % extra corpse removal rate (1/day), 0 = none

    % --- grid (spatial model) ---
    p.dx = 1;           % km per cell
    p.DE = 2.5;           % how fast exposed people spread (km^2/day)
    p.river_perm = 0.2; % how easily people cross the Thames
                        % (1 = like land, 0 = all bridges closed)

    if isfile('london_grid.mat')
        % real London-shaped grid (made by make_london_grid.m)
        g = load('london_grid.mat');
        p.Ncell  = g.Ncell;       % people per cell
        p.open   = g.open;        % true = inside London
        p.riverV = g.riverV;      % Thames between (i,j) and (i+1,j)
        p.riverH = g.riverH;      % Thames between (i,j) and (i,j+1)
        p.river_row = g.river_row;  p.river_col = g.river_col;   % for plots
        p.kings_cross = g.kings_cross;   % start cells [row col]
        p.morden      = g.morden;
    else
        % FAKE uniform 40 x 40 grid, no river (until london_grid.mat exists)
        warning('london_grid.mat not found - using the fake uniform grid');
        p.Ncell  = 5000 * ones(40);
        p.open   = true(40);
        p.riverV = false(39, 40);
        p.riverH = false(40, 39);
        p.kings_cross = [17 20];
        p.morden      = [32 15];
    end
    [p.nr, p.nc] = size(p.Ncell);

    % --- simulation ---
    p.tmax = 365;       % days
end
