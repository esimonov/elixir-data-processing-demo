# Data Generator

The starting point of the data processing pipeline, and arguably the simplest app under umbrella: it only consists of a single GenServer that simulates sensor readings and publishes them over MQTT. It's comprised of a single module with no additional layers of abstraction.

## Data description and format

The reported sensors are pre-defined. They are: humidity, pressure, and temperature.

The readings are normally distributed random values with `μ`s hardcoded as module attributes, and `σ²`s directly proportional to the ordinal number of the facility, e.g the higher the number of the facility, the more variance its sensor readings show. This is done in order to make the outputs in [Data Server](/apps/data_server/) more visually distinct.

The readings are JSON-encoded:

```json
{
  "ts": 1736798155662, // Unix timestamp in milliseconds
  "val": 1.2345 // Simulated sensor value
}
```

### Facility names

Facilities are assigned names based on their ordinal numbers. E.g, if number of facilities is configured to be 3, facility names would be `facility_1`, `facility_2`, and `facility_3`.

### MQTT topics

Each sensor has its own topic in the form of `sensor_readings/{facility_name}/{sensor_name}`. E.g, humidity sensor from facility_2 will publish its readings to the MQTT topic called `sensor_readings/facility_2/humidity`.

## Configuration

The following parameters are configurable:

- `:num_facilities` - The total number of facilities to simulate.
- `:reporting_interval` - Time interval between sensor reading simulations.
