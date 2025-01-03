defmodule DataServer.Consumer.ProtobufTest do
  use ExUnit.Case, async: true

  alias DataServer.Consumer.Protobuf

  describe "from_protobuf_interval/1" do
    test "converts valid Protobuf interval" do
      interval = %Schema.Interval{
        start_time: %Google.Protobuf.Timestamp{seconds: 1_607_799_999, nanos: 500_000},
        end_time: %Google.Protobuf.Timestamp{seconds: 1_607_999_999, nanos: 500_000}
      }

      result = Protobuf.from_protobuf_interval(interval)

      assert result == %{
               start_time: ~U[2020-12-12 19:06:39.000500Z],
               end_time: ~U[2020-12-15 02:39:59.000500Z]
             }
    end

    test "returns error for invalid timestamp" do
      {
        :error,
        :invalid_protobuf_data,
        "nil"
      }
    end
  end

  describe "from_protobuf_timestamp/1" do
    test "converts valid Protobuf timestamp" do
      timestamp = %Google.Protobuf.Timestamp{seconds: 1_607_999_999, nanos: 500_000}

      result = Protobuf.from_protobuf_timestamp(timestamp)

      assert result ==
               DateTime.from_unix!(1_607_999_999)
               |> DateTime.add(500, :microsecond)
    end

    test "returns error for invalid timestamp" do
      {
        :error,
        :invalid_protobuf_data,
        "nil"
      }
    end
  end
end
