defmodule DataServer.HTTPAPI.Handlers.SensorTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias DataServer.HTTPAPI.Handlers.Sensor

  import Mox

  setup :verify_on_exit!

  describe "find/1" do
    test "returns compacted readings with valid params" do
      # Define the mocked response
      readings = [
        %{
          "facility_name" => "facility_123",
          "start_time" => "2024-12-29T12:00:00Z",
          "end_time" => "2024-12-29T12:05:00Z",
          "avg_temperature" => 22.5,
          "max_temperature" => 25.0,
          "min_temperature" => 20.0
        },
        %{
          "facility_name" => "facility_123",
          "start_time" => "2024-12-29T12:05:00Z",
          "end_time" => "2024-12-29T12:10:00Z",
          "avg_temperature" => 23.0,
          "max_temperature" => 26.0,
          "min_temperature" => 21.0
        }
      ]

      expect(
        DataServer.MockStorage,
        :find,
        fn :compacted_reading, _, _ ->
          {:ok, readings, 3}
        end
      )

      conn =
        conn(:get, "/sensors/facility_123", %{
          "limit" => "10",
          "offset" => "1"
        })

      conn = Sensor.find(conn)

      response = Jason.decode!(conn.resp_body)

      assert conn.status == 200

      assert response["data"] == readings

      assert response["pagination"] == %{
               "limit" => 10,
               "offset" => 1,
               "total" => 3
             }
    end
  end
end
