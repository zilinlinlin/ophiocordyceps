import pygame
import matplotlib.pyplot as plt
import numpy as np
import time
import random
import math
import csv
from helper_functions import fit_line

# parameters
WIDTH, HEIGHT = 400, 300

cor = 1  # coefficient of restitution (1 for elastic collision)
num_people = 50*5
simulation_time = 30  # seconds
frames_per_second = 60
dt = 1.0 / frames_per_second  # time step

infection_chance = 0.25  # chance of infection upon collision

person_radius = 5  # radius of each person

class person:
    collision_times = [0] # List to store collision events by timestamp (dt)
    infection_times = [0] # List to store infection events by timestamp (dt)

    def __init__(self, x, y, vx, vy, m, r, infected=False):
        self.x = x
        self.y = y
        self.vx = vx
        self.vy = vy
        self.m = m
        self.r = r
        self.mom = m * math.sqrt(vx ** 2 + vy ** 2)
        self.k = 0.5 * m * (vx ** 2 + vy ** 2)
        self.infected = infected

    def update(self, dt):
        self.x += self.vx * dt
        self.y += self.vy * dt

    def draw(self, screen):
        # Evenly distribute colours based on mass from blue (light) to red (heavy)
        colour = (255, 255, 255)
        if self.infected:
            colour = (0, 255, 0)  # Green for infected

        pygame.draw.circle(screen, colour, (int(self.x), int(self.y)), self.r)

    def check_collision(self, other):
        distance = math.sqrt((self.x - other.x) ** 2 + (self.y - other.y) ** 2)
        return distance < self.r + other.r  # Check if the distance between centers is less than the sum of radii

    def wall_collision(self, t):
        if self.x - self.r < 0 or self.x + self.r > WIDTH:
            person.collision_times.append(t)  # Record the time of collision
            self.vx *= -cor
            self.x = max(self.r, min(self.x, WIDTH - self.r))
        if self.y - self.r < 0 or self.y + self.r > HEIGHT:
            person.collision_times.append(t)  # Record the time of collision
            self.vy *= -cor
            self.y = max(self.r, min(self.y, HEIGHT - self.r))

    def move_away(self, other, t):
        if self.check_collision(other):
            person.collision_times.append(t)  # Record the time of collision

            # Check for infection transmission
            if self.infected and not other.infected or other.infected and not self.infected:
                if random.random() < infection_chance:
                    other.infected = True
                    self.infected = True
                    person.infection_times.append(t)  # Record the time of infection

            # Calculate the normal vector
            dx = self.x - other.x
            dy = self.y - other.y
            distance = math.sqrt(dx ** 2 + dy ** 2)
            if distance == 0:
                return  # Avoid division by zero

            # Normalize the normal vector
            nx = dx / distance
            ny = dy / distance

            # Calculate relative velocity
            dvx = self.vx - other.vx
            dvy = self.vy - other.vy

            # Calculate relative velocity in terms of the normal direction
            rel_vel = dvx * nx + dvy * ny

            # Do not resolve if velocities are separating
            if rel_vel > 0:
                return

            # Calculate impulse scalar
            impulse = -(1 + cor) * rel_vel / (1 / self.m + 1 / other.m)

            # Apply impulse to the velocities
            self.vx += (impulse / self.m) * nx
            self.vy += (impulse / self.m) * ny
            other.vx -= (impulse / other.m) * nx
            other.vy -= (impulse / other.m) * ny


def spawn(amount):
    # Spawn people in with no collisions
    # Initialize people with random positions and velocities
    people = []
    for _ in range(num_people):
        colliding = True
        new_person = None
        while colliding:
            x = random.uniform(0, WIDTH)
            y = random.uniform(0, HEIGHT)
            vx = random.uniform(-50, 50)  # Random velocity in x direction
            vy = random.uniform(-50, 50)  # Random velocity in y direction
            m = random.uniform(1, 5)  # Random mass
            # depending on the mass, the radius ranges from 4 to 6
            r = 4 + (m - 1) * (6 - 4) / (5 - 1)  # Linear interpolation between 4 and 7 based on mass
            new_person = person(x, y, vx, vy, m, r)
            colliding = False
            for existing_person in people:
                if new_person.check_collision(existing_person):
                    colliding = True
                    break
        people.append(new_person)
    return people


def draw_screen(screen, people):
    screen.fill((0, 0, 0))  # Clear the screen with black
    for person in people:
        person.draw(screen)
    pygame.display.flip()

def main_loop():
    pygame.init()
    screen = pygame.display.set_mode((WIDTH, HEIGHT))
    clock = pygame.time.Clock()

    # Spawn people
    people = spawn(num_people)
    # infect a random person
    random.choice(people).infected = True

    for t in range(int(simulation_time * frames_per_second)):
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False

        # Update positions and check for collisions
        for i in range(len(people)):
            people[i].update(dt)
            people[i].wall_collision(t)
            for j in range(i + 1, len(people)):
                people[i].move_away(people[j], t)

        draw_screen(screen, people)
        #clock.tick(frames_per_second)

        if len(person.infection_times) == len(people):
            print(f"All people infected at time step {t}. Ending simulation.")
            pygame.quit()
            return t

    pygame.quit()
    t = int(simulation_time * frames_per_second)
    return t


t = main_loop()

# Plot collision events over time using matplotlib then fit a line to the same plot using first fit_line and then np.polyfit
collision_times = person.collision_times
collision_counts = range(len(collision_times))

infection_times = person.infection_times
infection_counts = range(len(infection_times))


time_steps = range(t)

# Clear and write collision times to a CSV file
with open('collision_times.csv', 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(['Time', 'Collision Time', 'Collision Count', 'Infection Time', 'Infection Count'])
    max_length = max(len(collision_times), len(collision_counts), len(infection_times), len(infection_counts))
    for i in range(max_length):
        collision_time = collision_times[i] if i < len(collision_times) else ''
        collision_count = collision_counts[i] if i < len(collision_counts) else ''
        infection_time = infection_times[i] if i < len(infection_times) else ''
        infection_count = infection_counts[i] if i < len(infection_counts) else ''
        writer.writerow([i, collision_time, collision_count, infection_time, infection_count])


# x = np.array(collision_times)

# w1, b1 = fit_line(list(zip(collision_times, range(len(collision_times))))) # fit_line expects a list of tuples
# w2, b2 = np.polyfit(collision_times, np.arange(len(collision_times)), 1)

# print(f"fit_line: slope={type(w1).__name__}({w1:.4f}), intercept={type(b1).__name__}({b1:.4f})")
# print(f"np.polyfit: slope={type(w2).__name__}({w2:.4f}), intercept={type(b2).__name__}({b2:.4f})")
# print(f"Collisions: {len(collision_times)}")

# plt.figure(figsize=(10, 5))
# plt.plot(collision_times, collision_counts, label='Collision Events', marker='o', linestyle='None')
# plt.plot(x, w1 * x + b1, color='red', linestyle=':', label='Fitted Line (fit_line)')
# plt.plot(x, w2 * x + b2, color='green', linestyle='--', label='Fitted Line (np.polyfit)')
# plt.title("Collision Events Over Time")
# plt.xlabel("Time (s)")
# plt.ylabel("Number of Collisions")
# plt.grid()
# plt.legend()
# plt.text(0.5, 0.1, f"fit_line: slope={w1:.4f}, intercept={b1:.4f}\nnp.polyfit: slope={w2:.4f}, intercept={b2:.4f}",
#          transform=plt.gca().transAxes, fontsize=10, verticalalignment='bottom')
# plt.show()