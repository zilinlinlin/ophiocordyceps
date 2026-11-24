import numpy as np
import matplotlib as plt
import pandas as pd
import json


# 32 London Boroughs, modeled by an 8x8 grid, with 4 cells unused and a border.
# Each cell represents a borough, and the grid is used to simulate interactions
# between them. Each cell will contain the 2021 census data for that borough's
# population density.
# The simulation will be divided into days, each day divided into 24 hours.
# Each hour, "people" have a chance to move to a neighboring borough,
# based on the job density of the boroughs during the working day (9am-5pm)
# and the residential density during the evening (5pm-9am).
# 18% of people who work in London live outside the city

# Jobs.csv and Population.csv contain the relevant data for each borough
# List of London Boroughs in alphabetical order with their population and job density

# read Jobs_2021.csv and Borough_denisty_2021.csv
pop_df = pd.read_csv("Borough_density_2021.csv", usecols=['Borough', 'Population Density'])
jobs_df = pd.read_csv("Jobs_2021.csv", usecols=['Borough', 'Jobs'])
boroughs_df = pd.merge(pop_df, jobs_df)
#print(boroughs_df['Population Density'].to_string())


london_pop = sum(boroughs_df['Population Density'])
london_jobs = sum(boroughs_df['Jobs'])


# build adjacency matrix
class adjacency_matrix:

    with open("neighbours.json", "r") as f:
        neighbours = json.load(f) # dict of adjacent boroughs

    borough2index = dict(zip(boroughs_df['Borough'].tolist(), range(len(boroughs_df['Borough'].tolist()))))


    def __init__(self, boroughs, buffer):
        self.boroughs = boroughs # for ease access of 
        self.rows = boroughs['Borough'].tolist() # all the boroughs
        self.cols = self.rows # all the boroughs again
        self.buffer = buffer # amount of people a borough will accept beyond average capacity


    def build_pop(self): # build the catual adjacency matrix
        matrix = np.zeros([len(self.rows), len(self.rows)])
        self.matrix = matrix
        # adjacency matrix that encodes movement probability from rows to columns
        for r in self.rows:
            row = adjacency_matrix.borough2index[r]
            current_pop = self.boroughs['Population Density'].iloc[row]
            for c in self.cols:
                col = adjacency_matrix.borough2index[c]
                next_pop = self.boroughs['Population Density'].iloc[col]

                # Softmax implementation (exp(next_pop) / sum(adjacent_pops)))


M = adjacency_matrix(boroughs_df, 10)
M.build_pop()

print(M.matrix)