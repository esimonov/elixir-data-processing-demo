defmodule Mix.Tasks.GenerateProto do
  @moduledoc false

  use Mix.Task

  @shortdoc "Compiles Protobuf schemas in the proto/ directory to Elixir modules."

  @proto_dir "proto/"
  @elixir_output_dir "lib/"

  def run(_args) do
    @proto_dir
    |> list_proto_files()
    |> Enum.each(&compile_proto_file/1)
  end

  defp list_proto_files(dir) do
    case File.ls(dir) do
      {:ok, files} ->
        files
        |> Enum.filter(&String.ends_with?(&1, ".proto"))
        |> Enum.map(&Path.join(dir, &1))

      {:error, reason} ->
        Mix.raise("Failed to list files in #{dir}: #{reason}")
    end
  end

  defp compile_proto_file(proto_file_path) do
    Mix.shell().info("Compiling #{proto_file_path}...")

    case run_protoc(proto_file_path, @elixir_output_dir) do
      :ok ->
        Mix.shell().info("Compiled #{proto_file_path} successfully!")

      {:error, reason} ->
        Mix.raise("Failed to compile #{proto_file_path}: #{reason}")
    end
  end

  defp run_protoc(proto_file_path, elixir_output_dir) do
    case System.cmd("protoc", ["--elixir_out=#{elixir_output_dir}", proto_file_path]) do
      {_, 0} -> :ok
      {error_message, _exit_code} -> {:error, error_message}
    end
  end
end
