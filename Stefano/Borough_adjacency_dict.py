import json

london_neighbours = {
    "Barking and Dagenham": [
        "Bexley", "Greenwich", "Havering", "Newham", "Redbridge"
    ],
    "Barnet": [
        "Brent", "Camden", "Enfield", "Haringey", "Harrow", "NW"
    ],
    "Bexley": [
        "Barking and Dagenham", "Bromley", "Greenwich", "Havering", "SE"
    ],
    "Brent": [
        "Barnet", "Camden", "Ealing", "Hammersmith and Fulham",
        "Harrow", "Kensington and Chelsea", "Westminster"
    ],
    "Bromley": [
        "Bexley", "Croydon", "Greenwich", "Lambeth",
        "Lewisham", "Southwark", "SE"
    ],
    "Camden": [
        "Barnet", "Brent", "City of London", "Haringey",
        "Islington", "Westminster"
    ],
    "City of London": [
        "Camden", "Hackney", "Islington", "Lambeth",
        "Southwark", "Tower Hamlets", "Westminster"
    ],
    "Croydon": [
        "Bromley", "Lambeth", "Merton", "Sutton", "SW", "SE"
    ],
    "Ealing": [
        "Brent", "Hammersmith and Fulham", "Harrow",
        "Hillingdon", "Hounslow"
    ],
    "Enfield": [
        "Barnet", "Haringey", "Waltham Forest", "NW", "NE"
    ],
    "Greenwich": [
        "Barking and Dagenham", "Bexley", "Bromley",
        "Lewisham", "Newham", "Tower Hamlets"
    ],
    "Hackney": [
        "City of London", "Haringey", "Islington", "Newham",
        "Tower Hamlets", "Waltham Forest"
    ],
    "Hammersmith and Fulham": [
        "Brent", "Ealing", "Hounslow", "Kensington and Chelsea",
        "Richmond upon Thames", "Wandsworth"
    ],
    "Haringey": [
        "Barnet", "Camden", "Enfield", "Hackney",
        "Islington", "Waltham Forest"
    ],
    "Harrow": [
        "Barnet", "Brent", "Ealing", "Hillingdon", "NW"
    ],
    "Havering": [
        "Barking and Dagenham", "Bexley", "Redbridge", "NE", "SE"
    ],
    "Hillingdon": [
        "Ealing", "Harrow", "Hounslow", "NW", "SW"
    ],
    "Hounslow": [
        "Ealing", "Hammersmith and Fulham", "Hillingdon",
        "Richmond upon Thames", "SW"
    ],
    "Islington": [
        "Camden", "City of London", "Hackney", "Haringey"
    ],
    "Kensington and Chelsea": [
        "Brent", "Hammersmith and Fulham", "Wandsworth", "Westminster"
    ],
    "Kingston upon Thames": [
        "Merton", "Richmond upon Thames", "Sutton", "Wandsworth", "SW"
    ],
    "Lambeth": [
        "Bromley", "City of London", "Croydon", "Merton",
        "Southwark", "Wandsworth", "Westminster"
    ],
    "Lewisham": [
        "Bromley", "Greenwich", "Southwark", "Tower Hamlets"
    ],
    "Merton": [
        "Croydon", "Kingston upon Thames", "Lambeth",
        "Sutton", "Wandsworth"
    ],
    "Newham": [
        "Barking and Dagenham", "Greenwich", "Hackney",
        "Redbridge", "Tower Hamlets", "Waltham Forest"
    ],
    "Redbridge": [
        "Barking and Dagenham", "Havering", "Newham",
        "Waltham Forest", "NE"
    ],
    "Richmond upon Thames": [
        "Hammersmith and Fulham", "Hounslow",
        "Kingston upon Thames", "Wandsworth", "SW"
    ],
    "Southwark": [
        "Bromley", "City of London", "Lambeth",
        "Lewisham", "Tower Hamlets"
    ],
    "Sutton": [
        "Croydon", "Kingston upon Thames", "Merton", "SW"
    ],
    "Tower Hamlets": [
        "City of London", "Greenwich", "Hackney",
        "Lewisham", "Newham", "Southwark"
    ],
    "Waltham Forest": [
        "Enfield", "Hackney", "Haringey", "Newham", "Redbridge", "NE"
    ],
    "Wandsworth": [
        "Hammersmith and Fulham", "Kensington and Chelsea",
        "Kingston upon Thames", "Lambeth", "Merton",
        "Richmond upon Thames", "Westminster"
    ],
    "Westminster": [
        "Brent", "Camden", "City of London",
        "Kensington and Chelsea", "Lambeth", "Wandsworth"
    ],
}

json_str = json.dumps(london_neighbours, indent=4)

with open("neighbours.json", "w") as f:
    f.write(json_str)