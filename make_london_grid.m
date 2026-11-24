%% MAKE_LONDON_GRID  Build the London-shaped 1 km grid with the River Thames.
%  Inputs (in this folder):
%    london_lsoa_pop_2024.csv - ONS mid-2024 population for London's 4,994 LSOAs
%    lsoa_latlong.csv         - LSOA population-weighted centroids (lat/long),
%                               github.com/drkane/geo-lookups (ONS data, OGL v3)
%  Output: london_grid.mat with
%    Ncell          people per 1 km cell (nr x nc)
%    open           true = part of London (people can be there), false = outside
%    riverV, riverH true = the Thames runs between these two neighbouring cells
%                   riverV: between (i,j) and (i+1,j);  riverH: between (i,j) and (i,j+1)
%    kings_cross, morden    start cells [row col]
%    river_row, river_col   the Thames in grid coordinates (for plotting)
%
%  Method:
%  - lat/long -> km east/north of Charing Cross (local flat-earth approximation,
%    accurate to well under 1 km across London)
%  - each LSOA's population goes into the cell containing its centroid
%  - London = cells with people (one-cell corner gaps closed), plus empty
%    cells fully enclosed by them (parks, reservoirs), keeping only the part
%    connected to central London; everything else is outside and closed off
%  - the Thames is a traced centreline; a face between two cells is "river"
%    if the line joining the two cell centres crosses it
clear; clc; close all;

latC = 51.5074;  lonC = -0.1278;            % centre: Charing Cross
kmlat = 110.57;  kmlon = 111.32 * cosd(latC);
toxy = @(lat, lon) deal((lon - lonC) * kmlon, (lat - latC) * kmlat);  % km east, km north

%% Population and centroids
pop  = readtable('london_lsoa_pop_2024.csv');
cent = readtable('lsoa_latlong.csv');
vn = cent.Properties.VariableNames;  lv = lower(vn);
codeCol = vn{find(ismember(lv, {'lsoacd', 'lsoa21cd'}), 1)};
latCol  = vn{find(startsWith(lv, 'lat'), 1)};
lonCol  = vn{find(startsWith(lv, 'lon'), 1)};
cent = cent(:, {codeCol, latCol, lonCol});
cent.Properties.VariableNames = {'LSOA21CD', 'lat', 'lon'};
[~, keep] = unique(cent.LSOA21CD, 'stable');
cent = cent(keep, :);

T = innerjoin(pop, cent, 'Keys', 'LSOA21CD');
fprintf('Matched %d of %d London LSOAs\n', height(T), height(pop));

%% Grid that just covers London (1 km cells, 1 km margin)
[x, y] = toxy(T.lat, T.lon);
xmin = floor(min(x)) - 1;  xmax = ceil(max(x)) + 1;
ymin = floor(min(y)) - 1;  ymax = ceil(max(y)) + 1;
nc = xmax - xmin;  nr = ymax - ymin;
tocell = @(x, y) [floor(ymax - y) + 1, floor(x - xmin) + 1];   % [row col], row 1 = north

Ncell = accumarray(tocell(x, y), T.population, [nr nc]);

%% London mask
% 1) cells with people; close one-cell gaps so cells that only touch at a
%    corner get joined (people can only move north/south/east/west)
has_people = Ncell > 0;
london = ~dilate8(~dilate8(has_people)) | has_people;
% 2) add empty cells fully enclosed by London (parks, reservoirs)
outside = false(nr, nc);
outside([1 nr], :) = ~london([1 nr], :);
outside(:, [1 nc]) = outside(:, [1 nc]) | ~london(:, [1 nc]);
while true
    grow = outside;
    grow(2:end, :)   = grow(2:end, :)   | outside(1:end-1, :);
    grow(1:end-1, :) = grow(1:end-1, :) | outside(2:end, :);
    grow(:, 2:end)   = grow(:, 2:end)   | outside(:, 1:end-1);
    grow(:, 1:end-1) = grow(:, 1:end-1) | outside(:, 2:end);
    grow = grow & ~london;
    if isequal(grow, outside), break; end
    outside = grow;
end
open = ~outside;

%% River Thames centreline [lat lon], west (Hampton) to east (beyond Erith)
%  Checked: all 3,524 LSOAs in boroughs entirely on one bank fall on the correct side.
river = [51.4085 -0.3720; 51.4036 -0.3378; 51.4115 -0.3087; 51.4302 -0.3245;
         51.4455 -0.3253; 51.4570 -0.3070; 51.4717 -0.3196; 51.4878 -0.2878;
         51.4730 -0.2690; 51.4720 -0.2530; 51.4882 -0.2302; 51.4668 -0.2131;
         51.4650 -0.1880; 51.4808 -0.1717; 51.4850 -0.1500; 51.4840 -0.1380;
         51.4875 -0.1265; 51.5008 -0.1218; 51.5085 -0.1167; 51.5089 -0.1045;
         51.5079 -0.0877; 51.5055 -0.0754; 51.5025 -0.0600; 51.5085 -0.0390;
         51.5000 -0.0300; 51.4850 -0.0280; 51.4835 -0.0099; 51.4880 -0.0020;
         51.5020 -0.0010; 51.5070  0.0040; 51.4980  0.0150; 51.4966  0.0370;
         51.4945  0.0620; 51.5060  0.0850; 51.5140  0.1300; 51.5110  0.1650;
         51.4920  0.1850; 51.4760  0.2100; 51.4600  0.2700; 51.4550  0.3300];
[rx, ry] = toxy(river(:,1), river(:,2));

cx = xmin + (1:nc) - 0.5;      % cell centre, km east
cy = ymax - (1:nr) + 0.5;      % cell centre, km north

riverV = false(nr-1, nc);
for i = 1:nr-1
    for j = 1:nc
        riverV(i,j) = crosses_river([cx(j) cy(i)], [cx(j) cy(i+1)], rx, ry);
    end
end
riverH = false(nr, nc-1);
for i = 1:nr
    for j = 1:nc-1
        riverH(i,j) = crosses_river([cx(j) cy(i)], [cx(j+1) cy(i)], rx, ry);
    end
end
river_col = rx - xmin + 0.5;   % river in grid coordinates (for plots)
river_row = ymax - ry + 0.5;

%% Start cells
[kx, ky] = toxy(51.5308, -0.1238);  kings_cross = tocell(kx, ky);   % King's Cross St Pancras
[mx, my] = toxy(51.4022, -0.1948);  morden      = tocell(mx, my);   % Morden station

%% Keep only the part of London connected to the centre
% (any leftover edge cells that no one could walk to are dropped)
reach = false(nr, nc);
reach(kings_cross(1), kings_cross(2)) = true;
while true
    grow = reach;
    grow(2:end, :)   = grow(2:end, :)   | reach(1:end-1, :);
    grow(1:end-1, :) = grow(1:end-1, :) | reach(2:end, :);
    grow(:, 2:end)   = grow(:, 2:end)   | reach(:, 1:end-1);
    grow(:, 1:end-1) = grow(:, 1:end-1) | reach(:, 2:end);
    grow = grow & open;
    if isequal(grow, reach), break; end
    reach = grow;
end
fprintf('Dropped %s people in cut-off edge cells\n', num2str(sum(Ncell(open & ~reach))));
open = reach;
Ncell(~open) = 0;

%% Report and save
fprintf('Grid: %d rows x %d cols (1 km cells), %d cells in London\n', nr, nc, nnz(open));
fprintf('Population on grid: %s\n', num2str(sum(Ncell(:))));
fprintf('River faces: %d\n', nnz(riverV) + nnz(riverH));
fprintf('King''s Cross cell [%d %d] (%s people), Morden cell [%d %d] (%s people)\n', ...
        kings_cross, num2str(Ncell(kings_cross(1), kings_cross(2))), ...
        morden,      num2str(Ncell(morden(1), morden(2))));

save('london_grid.mat', 'Ncell', 'open', 'riverV', 'riverH', 'river_row', 'river_col', ...
     'kings_cross', 'morden', 'xmin', 'ymax', 'latC', 'lonC');

figure;
imagesc(Ncell, 'AlphaData', double(open)); axis image; colorbar; hold on;
plot(river_col, river_row, 'c-', 'LineWidth', 2);
plot(kings_cross(2), kings_cross(1), 'r*', 'MarkerSize', 10);
plot(morden(2), morden(1), 'ro', 'MarkerSize', 8);
legend('Thames', 'King''s Cross', 'Morden', 'Location', 'southwest');
title('People per 1 km cell (ONS mid-2024)');

%% Local functions
function out = dilate8(m)
% Grow a logical mask by one cell in all 8 directions.
    [nr, nc] = size(m);
    P = false(nr + 2, nc + 2);
    P(2:end-1, 2:end-1) = m;
    out = false(nr, nc);
    for di = -1:1
        for dj = -1:1
            out = out | P((2:nr+1) + di, (2:nc+1) + dj);
        end
    end
end

function hit = crosses_river(a, b, rx, ry)
% True if the segment a-b crosses any segment of the river polyline.
    q1x = rx(1:end-1);  q1y = ry(1:end-1);
    q2x = rx(2:end);    q2y = ry(2:end);
    d1 = (b(1)-a(1)) .* (q1y-a(2)) - (b(2)-a(2)) .* (q1x-a(1));
    d2 = (b(1)-a(1)) .* (q2y-a(2)) - (b(2)-a(2)) .* (q2x-a(1));
    d3 = (q2x-q1x) .* (a(2)-q1y) - (q2y-q1y) .* (a(1)-q1x);
    d4 = (q2x-q1x) .* (b(2)-q1y) - (q2y-q1y) .* (b(1)-q1x);
    hit = any(d1 .* d2 < 0 & d3 .* d4 < 0);
end
