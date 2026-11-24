import numpy as np
import matplotlib.pyplot as plt

def fit_line(coordinates):
    """
    Fit a line to the given coordinates using linear regression.

    Parameters:
    coordinates (list of tuples): A list of (x, y) tuples representing the coordinates.

    Returns:
    tuple: A tuple containing the slope and intercept of the fitted line.
    """

    if np.shape(coordinates) != (len(coordinates), 2):
        raise ValueError("The list of coordinates is wrong dimension.")
    elif not all(isinstance(x, (int, float)) and isinstance(y, (int, float)) for x, y in coordinates):
        print(f"Data type of coordinates: {type(coordinates)}")
        raise TypeError("The coordinates must be numeric.")

    X, Y = zip(*coordinates)
    X = np.array(X)
    Y = np.array(Y)
    print(f"X: {X}\n\n Y: {Y}")

    # Calculate the slope (w) and intercept (b) using linear regression formulas
    m = len(X)
    if m == 0:
        raise ValueError("The list of coordinates is empty.")

    # Initial slope (w) and intercept (b) values
    initial_w = 1.0
    initial_b = 0.0

    # Gradient descent parameters
    learning_rate = 0.01
    num_iterations = 5000
    

    w = initial_w
    b = initial_b

    # using matrix operations to calculate the slope and intercept
    for _ in range(num_iterations):
        # Calculate the gradients
        dw = (1/m) * np.sum((w*X + b - Y) * X, dtype=np.float64)
        db = (1/m) * np.sum(w*X + b - Y, dtype=np.float64)

        if _ % 500 == 0:  # Print every 500 iterations
            print(f"Iteration {_}: w={w}, b={b}")

        # Update the parameters
        w -= learning_rate * dw
        b -= learning_rate * db

    #w = round(w, 4)
    #b = round(b, 4)

    return w, b



def __test_fit_line():
    x = [0, 1, 2, 2, 4, 5, 7, 7, 8, 9]
    y = [0, 1, 2, 4, 4, 5, 5, 7, 8, 9]
    line_to_fit = list(zip(x, y))  # A simple line y = x
    slope, intercept = fit_line(line_to_fit)
    slope_np, intercept_np = np.polyfit([x for x, y in line_to_fit], [y for x, y in line_to_fit], 1)

    plt.plot([x for x, y in line_to_fit], [y for x, y in line_to_fit], 'o', label='Data Points')
    plt.plot([x for x, y in line_to_fit], [slope * x + intercept for x, y in line_to_fit], label='Fitted Line')
    plt.plot([x for x, y in line_to_fit], [slope_np * x + intercept_np for x, y in line_to_fit], label='Numpy Fitted Line', linestyle='--')
    plt.title(f"Fitted Line: y = {slope}x + {intercept}\nNumpy Fitted Line: y = {slope_np}x + {intercept_np}")
    plt.xlabel("X-axis")
    plt.ylabel("Y-axis")
    plt.legend()
    plt.grid()
    plt.show()

if __name__ == "__main__":
    __test_fit_line()