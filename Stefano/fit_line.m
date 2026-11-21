function [w, b] = fit_line(coords, num_iterations, learning_rate)
    
    default_learning_rate = 10e-6;
    default_num_iterations = 10000;

    if nargin < 2
        num_iterations = default_num_iterations;
        learning_rate = default_learning_rate;
    elseif nargin < 3
        learning_rate = default_learning_rate;
    end

    % coords is a list of tuples
    X = coords(:, 1);
    Y = coords(:, 2);
    m = size(coords, 1);

    w = 0;  b = 0; % intialised to an arbitrary value    

    for i = 1:num_iterations
        B = b.*ones(m, 1);

        dw = sum((w.*X + B - Y) .* X)/m;
        db = sum(w.*X + B - Y)/m;
        
        w = w - dw*learning_rate;
        b = b - db*learning_rate;
    end

end