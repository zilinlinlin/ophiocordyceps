# ModSim code

| Order | Script | What it does | Expected output (default params) |
|---|---|---|---|
| 0 | `make_london_grid.m` | Builds the London-shaped grid with the Thames (needs `london_lsoa_pop_2024.csv` + `lsoa_latlong.csv`) | 46 × 58 grid, 4994/4994 LSOAs matched, 2,205 people dropped (cut-off edge cells), King's Cross [19 28], Morden [33 23] |
| 1 | `run_single_node.m` | Well-mixed S-E-F-D model of all London | R0 = 3.00 from Wells–Riley; spores clear in ≈ 35 min; R0 ≈ 588 at full exposure; 50% infected ≈ day 135.6, final size 0.9405 (= theory), conservation error ≈ 0 |
| 2 | `removal_sweep.m` | Corpse-removal intervention sweep | Outbreak stops when removal > 0.143/day (corpses removed within ~7 days) |
| 3 | `compare_locations.m` | King's Cross vs Morden on the London grid | 50% at ≈ day 143.2 (KX) vs ≈ 152.2 (Morden); final size ≈ 0.883 |
| 4 | `river_experiment.m` | How much the Thames matters | see table below |
| 4b | `plot_compartments.m` | Graph of each phase (S, E, F, D) vs time: single node vs grid from King's Cross vs Morden | 4 panels + peak sizes and days |
| 5 | `wave_speed_check.m` | Validation: front speed vs theory (plain 40 × 40 grid) | measured ≈ 0.51, theory ≈ 0.52 km/day |

### Expected `river_experiment.m` output (DE = 2, R0 = 3)
| River permeability | KX: 50% at | Morden: 50% at | Final size |
|---|---|---|---|
| 1 (like land) | 143.1 d | 151.2 d | 0.883 |
| 0.2 (default) | 143.2 d | 152.2 d | 0.883 |
| 0.05 | 144.0 d | 155.2 d | 0.884 |
| 0 (all crossings closed) | 163.9 d | never | KX 0.567, Morden 0.317 |

With the river closed, each outbreak is trapped on its own bank, and an outbreak
starting south of the river (Morden) can never reach 50% of London.

## Functions (called by the scripts)
- `params_default.m` – every parameter in one struct `p`; loads `london_grid.mat` if it exists, otherwise a fake uniform 40 × 40 grid
- `wells_riley_beta.m` – transmission rate β (and R0) from breathing rate, spore emission, ventilation, spore decay and exposure time
- `sefd_rhs.m` – single-node equations
- `sefd_grid_rhs.m` – grid equations (method of lines)
- `laplacian_faces.m` – diffusion as flows across cell faces (closed London edge, reduced flow across the Thames)
- `run_grid_scenario.m` – solves the grid from a seed; returns results in the agreed format
- `wave_speed_theory.m` – theoretical front speed (only E moves, so not 2√(D·r))

## Data
- `london_lsoa_pop_2024.csv` – ONS mid-2024 LSOA population, London only (from `sapelsoabroadage20222024.xlsx`)
- `lsoa_latlong.csv` – LSOA population-weighted centroids, github.com/drkane/geo-lookups (ONS, Open Government Licence v3)
- Thames centreline traced in `make_london_grid.m`; checked against 3,524 LSOAs in boroughs entirely on one bank (all on the correct side)

## Transmission (Wells–Riley, Edwards et al. 2024)
β = f · breathing rate · spore emission / air cleaned per person, with f = exposure minutes per day / 1440.
Values: breathing 0.01 m³/min and emission 6 quanta/min (Edwards, SARS-CoV-2), ventilation ~10 L/s per person
(UK guidance, check), spore inactivation 0.00525/min and deposition 0.015/min (Edwards midpoints).

Two findings worth reporting:
- If everyone in a 1 km cell breathed a corpse's air all day, R0 ≈ 588 and half of London is infected in ~4 days.
  The exposure time (`p.exposure_min`) is what makes the outbreak realistic: 7.35 min/day gives R0 = 3.
- Spores clear from the air in ~35 min, so on a timescale of days the spore concentration is always at
  steady state and no separate spore variable is needed (a long-lived fungal spore would change this).

## Placeholders to replace
- `p.exposure_min = 7.35` → minutes per day a person breathes a corpse's air (now the main transmission knob)
- `p.vol_pp = 72` → indoor air volume per person (m³)
- `p.DE = 2` → movement of people (km²/day); a smaller value makes the start location matter more
- `p.river_perm = 0.2` → how easily people cross the Thames
