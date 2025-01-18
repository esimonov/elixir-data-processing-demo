# Data Server

The ending point of the data processing pipeline: this app subscribes to the data published by [Data Compactor](/apps/data_compactor/), saves is to MongoDB, and serves via HTTP.

## Endpoints

The server serves two HTTP endpoints:

1. `GET /api/sensors/:facility_name?offset=0&limit=10` for fetching the list of sensor readings for a particular facility. The entries are sorted by `startTime` in descending order.

Pagination parameters are optional. If not provided, `offset` is assumed to be `0`, and `limit` is assumed to be `@default_limit`. If provided `limit` exceeds `@max_limit`, `@max_limit` is assumed.

Example request:

```sh
curl "http://localhost:8080/api/sensors/facility_1?limit=2&offset=1"
```

Example response:

```json
{
  "data": [
    {
      "avg_humidity": 49.62084582340565,
      "avg_pressure": 1009.0313780042974,
      "avg_temperature": 20.88573987783014,
      "facility_name": "facility_1",
      "max_humidity": 50.05807068386527,
      "max_pressure": 1010.207166453653,
      "max_temperature": 21.047709367998948,
      "min_humidity": 49.18362096294604,
      "min_pressure": 1007.8555895549417,
      "min_temperature": 20.723770387661332,
      "received_at": "2025-01-18T09:29:52.404Z",
      "window": {
        "end_time": "2025-01-18T09:29:52.338Z",
        "start_time": "2025-01-18T09:29:42.337Z"
      }
    },
    {
      "avg_humidity": 51.325469578344865,
      "avg_pressure": 1013.4614665580898,
      "avg_temperature": 20.054583247295707,
      "facility_name": "facility_1",
      "max_humidity": 51.82148836781221,
      "max_pressure": 1014.9736946349968,
      "max_temperature": 20.259553705392378,
      "min_humidity": 50.829450788877516,
      "min_pressure": 1011.9492384811826,
      "min_temperature": 19.849612789199035,
      "received_at": "2025-01-18T09:29:44.351Z",
      "window": {
        "end_time": "2025-01-18T09:29:42.327Z",
        "start_time": "2025-01-18T09:29:32.326Z"
      }
    }
  ],
  "pagination": {
    "offset": 1,
    "total": 84,
    "limit": 2
  }
}
```

Example bad request:

```sh
curl "http://localhost:8080/api/sensors/facility_1?limit=abc"
```

Example error response:

```json
{
  "error": "Invalid limit: must be a non-negative integer; got 'abc'"
}
```

2. `GET /api/stats?sensors=humidity,temperature,pressure` for fetching statistics for specific sensors across all the facilities. Any variation of the three sensor names are accepted, but at least one of them must be provided. Nonexistent sensor names will be skipped if at least one valid sensor name is also provided.

Example request:

```sh
curl "http://localhost:8080/api/stats?sensors=pressure"
```

Example response:

```json
[
  {
    "_id": "facility_1",
    "pressure": {
      "stdev": 4.295840321841032
    }
  },
  {
    "_id": "facility_2",
    "pressure": {
      "stdev": 7.003253273075151
    }
  },
  {
    "_id": "facility_3",
    "pressure": {
      "stdev": 7.038146593295677
    }
  }
]
```

Example bad request:

```sh
curl "http://localhost:8080/api/stats?sensors="
```

Example error response:

```json
{
  "error": "At least one valid sensor name must be provided"
}
```

## Configuration

The following parameters are configurable:

- `:default_limit` - Default value for the `limit` pagination parameter when none is provided.
- `:max_limit` - Maximum value for the `limit` pagination parameter. Limits exceeding this value will be capped.
