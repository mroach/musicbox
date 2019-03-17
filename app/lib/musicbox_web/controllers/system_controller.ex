defmodule MusicboxWeb.SystemController do
  use MusicboxWeb, :controller

  def alive(conn, _params) do
    text(conn, "OK")
  end

  def stats(conn, _params) do
    {{:input, input}, {:output, output}} = :erlang.statistics(:io)

    hostname = case :inet.gethostname do
      {:ok, hostname} -> hostname |> to_string
      _ -> nil
    end

    data = %{
      "elixir" => System.build_info,
      "erlang" => %{
        "schedulers"              => :erlang.system_info(:schedulers),
        "uptime_s"                => :erlang.statistics(:wall_clock) |> elem(0) |> Kernel.div(1000),
        "cpu_time_s"              => :erlang.statistics(:runtime) |> elem(0) |> Kernel.div(1000),
        "io_input"                => input,
        "io_output"               => output,
        "total_run_queue_lengths" => :erlang.statistics(:total_run_queue_lengths),
        "atom_count"              => :erlang.system_info(:atom_count),
        "process_count"           => :erlang.system_info(:process_count),
        "port_count"              => :erlang.system_info(:port_count),
        "ets_count"               => length(:ets.all()),
        "memory"                  => Map.new(:erlang.memory()),
        "node"                    => :erlang.node |> to_string()
      },
      "system" => %{
        "processors" => :erlang.system_info(:logical_processors_available),
        "os_type"    => :os.type |> Tuple.to_list |> Enum.join("/"),
        "os_version" => :os.version |> Tuple.to_list |> Enum.join("."),
        "arch"       => :erlang.system_info(:system_architecture) |> to_string,
        "time"       => :os.system_time |> System.convert_time_unit(:nanosecond, :second)
      },
      "net" => %{
        "hostname" => hostname
      }
    }

    json(conn, data)
  end
end
