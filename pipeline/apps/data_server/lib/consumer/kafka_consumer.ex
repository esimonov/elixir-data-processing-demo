defmodule DataServer.KafkaConsumer do
  use Broadway

  def start_link(_) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {
          BroadwayKafka.Producer,
          Application.get_env(:data_server, :kafka_consumer)
        },
        concurrency: 1
      ],
      processors: [
        default: [
          concurrency: 10
        ]
      ]
    )
  end

  def handle_message(_, %Broadway.Message{data: data} = message, _context) do
    data
    |> Schema.AggregatedDocument.decode()
    |> save_to_database()

    message
  end

  defp save_to_database(document = %Schema.AggregatedDocument{}) do
    IO.puts("Saving to Database! #{inspect(document)}")
  end
end
