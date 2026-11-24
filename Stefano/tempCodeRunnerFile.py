x = np.array(collision_times)

w1, b1 = fit_line(list(zip(collision_times, range(len(collision_times))))) # fit_line expects a list of tuples
w2, b2 = np.polyfit(collision_times, np.arange(len(collision_times)), 1)

print(f"fit_line: slope={type(w1).__name__}({w1:.4f}), intercept={type(b1).__name__}({b1:.4f})")
print(f"np.polyfit: slope={type(w2).__name__}({w2:.4f}), intercept={type(b2).__name__}({b2:.4f})")
print(f"Collisions: {len(collision_times)}")

plt.figure(figsize=(10, 5))
plt.plot(collision_times, collision_counts, label='Collision Events', marker='o', linestyle='None')
plt.plot(x, w1 * x + b1, color='red', linestyle=':', label='Fitted Line (fit_line)')
plt.plot(x, w2 * x + b2, color='green', linestyle='--', label='Fitted Line (np.polyfit)')
plt.title("Collision Events Over Time")
plt.xlabel("Time (s)")
plt.ylabel("Number of Collisions")
plt.grid()
plt.legend()
plt.text(0.5, 0.1, f"fit_line: slope={w1:.4f}, intercept={b1:.4f}\nnp.polyfit: slope={w2:.4f}, intercept={b2:.4f}",
         transform=plt.gca().transAxes, fontsize=10, verticalalignment='bottom')
plt.show()