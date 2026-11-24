function L = laplacian_faces(U, Kv, Kh, dx)
% LAPLACIAN_FACES  Diffusion on the grid, written as flows across cell faces.
%   U  : nr x nc field (e.g. exposed people per cell)
%   Kv : (nr-1) x nc permeability of the face between (i,j) and (i+1,j)
%   Kh : nr x (nc-1) permeability of the face between (i,j) and (i,j+1)
%        1 = normal, 0 = blocked (outside London), 0..1 = river crossing
%   Whatever leaves one cell enters its neighbour, so people are conserved.
%   With all K = 1 this is the standard 5-point Laplacian with a closed edge.

    L = zeros(size(U));

    fv = Kv .* (U(2:end, :) - U(1:end-1, :));   % flow across north-south faces
    L(1:end-1, :) = L(1:end-1, :) + fv;
    L(2:end, :)   = L(2:end, :)   - fv;

    fh = Kh .* (U(:, 2:end) - U(:, 1:end-1));   % flow across east-west faces
    L(:, 1:end-1) = L(:, 1:end-1) + fh;
    L(:, 2:end)   = L(:, 2:end)   - fh;

    L = L / dx^2;
end
