# Data Generator

The starting point of the data processing pipeline, and arguably the simplest app under umbrella: it only consists of a single GenServer that simulates sensor readings and publishes them over MQTT. It's comprised of a single module with no additional layers of abstraction.

## Data description and format

The reported sensors are pre-defined. They are: humidity, pressure, and temperature.

The readings are normally distributed random values with μs hardcoded as module attributes, and σ²s directly proportional to the ordinal number of the facility, e.g the higher the number of the facility, the more variance its sensor readings show. This is done in order to make the outputs in [Data Server](/apps/data_server/) more visually distinct.

## Configuration

The following parameters are configurable:

- `:num_facilities` - The total number of facilities to simulate.
- `:reporting_interval` - Time interval between sensor reading simulations.
