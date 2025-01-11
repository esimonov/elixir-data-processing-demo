defmodule Schema.Helpers.DecoderTest do
  use ExUnit.Case, async: true

  alias Schema.Helpers.Decoder

  describe "decode_map/1" do
    test "decodes Schema.CompactedReading" do
      result =
        %Schema.CompactedReading{
          facility_name: "test_id",
          avg_humidity: 1.0,
          avg_temperature: 2.0,
          avg_pressure: 3.0,
          max_humidity: 4.0,
          max_temperature: 5.0,
          max_pressure: 6.0,
          min_humidity: 7.0,
          min_temperature: 8.0,
          min_pressure: 9.0,
          window: %Schema.Interval{
            start_time: %Google.Protobuf.Timestamp{seconds: 1_607_799_999, nanos: 500_000},
            end_time: %Google.Protobuf.Timestamp{seconds: 1_607_999_999, nanos: 500_000}
          }
        }
        |> Decoder.decode_map()

      assert result ==
               {
                 :ok,
                 %{
                   facility_name: "test_id",
                   avg_humidity: 1.0,
                   avg_temperature: 2.0,
                   avg_pressure: 3.0,
                   max_humidity: 4.0,
                   max_temperature: 5.0,
                   max_pressure: 6.0,
                   min_humidity: 7.0,
                   min_temperature: 8.0,
                   min_pressure: 9.0,
                   window: %{
                     start_time: ~U[2020-12-12 19:06:39.000500Z],
                     end_time: ~U[2020-12-15 02:39:59.000500Z]
                   },
                   __unknown_fields__: []
                 }
               }
    end

    test "returns error for unknown type" do
      result = Decoder.decode_map("string")

      assert result == {:error, :invalid_data, "\"string\""}
    end
  end

  describe "from_protobuf_interval/1" do
    test "converts valid Protobuf interval" do
      interval = %Schema.Interval{
        start_time: %Google.Protobuf.Timestamp{seconds: 1_607_799_999, nanos: 500_000},
        end_time: %Google.Protobuf.Timestamp{seconds: 1_607_999_999, nanos: 500_000}
      }

      result = Decoder.from_protobuf_interval(interval)

      assert result ==
               {
                 :ok,
                 %{
                   start_time: ~U[2020-12-12 19:06:39.000500Z],
                   end_time: ~U[2020-12-15 02:39:59.000500Z]
                 }
               }
    end

    test "returns error for invalid interval" do
      result = Decoder.from_protobuf_interval(nil)

      assert result == {:error, :invalid_data, "nil"}
    end
  end

  describe "from_protobuf_timestamp/1" do
    test "converts valid Protobuf timestamp" do
      timestamp = %Google.Protobuf.Timestamp{seconds: 1_607_999_999, nanos: 500_000}

      result = Decoder.from_protobuf_timestamp(timestamp)

      expected_dt =
        DateTime.from_unix!(1_607_999_999)
        |> DateTime.add(500, :microsecond)

      assert result == {:ok, expected_dt}
    end

    test "returns error for invalid timestamp" do
      result = Decoder.from_protobuf_timestamp(nil)

      assert result == {:error, :invalid_data, "nil"}
    end
  end
end
