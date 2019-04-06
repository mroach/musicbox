defmodule SystemInfo do
  def elixir_info, do: System.build_info()

  def vm_stats do
    {{:input, input}, {:output, output}} = :erlang.statistics(:io)

    %{
      schedulers:              :erlang.system_info(:schedulers),
      uptime_s:                :erlang.statistics(:wall_clock) |> elem(0) |> Kernel.div(1000),
      cpu_time_s:              :erlang.statistics(:runtime) |> elem(0) |> Kernel.div(1000),
      io_input:                input,
      io_output:               output,
      total_run_queue_lengths: :erlang.statistics(:total_run_queue_lengths),
      atom_count:              :erlang.system_info(:atom_count),
      process_count:           :erlang.system_info(:process_count),
      port_count:              :erlang.system_info(:port_count),
      ets_count:               length(:ets.all()),
      memory:                  Map.new(:erlang.memory()),
      node:                    :erlang.node() |> to_string()
    }
  end

  def product do
    product_model() || vendor_and_product()
  end

  def platform do
    %{
      os_type:    :os.type() |> Tuple.to_list() |> Enum.join("/"),
      os_version: :os.version() |> Tuple.to_list() |> Enum.join("."),
      arch:       :erlang.system_info(:system_architecture) |> to_string,
      time:       :os.system_time() |> System.convert_time_unit(:nanosecond, :second)
    }
  end

  def hardware do
    %{
      processors: :erlang.system_info(:logical_processors_available),
      processor_model: processor_model()
    }
  end

  def network do
    %{
      hostname: hostname()
    }
  end

  def hostname do
    case :inet.gethostname() do
      {:ok, hostname} -> hostname |> to_string
      _ -> nil
    end
  end

  def processor_model do
    cpu_info()
    |> Enum.at(0, %{})
    |> Map.get("model name", "")
  end

  def cpu_info do
    :os.type |> cpus()
  end

  defp cpus({_, :linux}) do
    File.read!("/proc/cpuinfo")
    |> String.split("\n\n")
    |> Enum.filter(fn s -> String.starts_with?(s, "processor") end)
    |> Enum.map(fn s ->
      s
      |> String.split("\n")
      |> Enum.map(fn line -> line |> String.split(~r/\t*:\s*/) |> List.to_tuple end)
      |> Map.new
    end)
  end
  defp cpus(_), do: []

  defp vendor_and_product do
    [vendor(), product_name()]
    |> Enum.reject(&is_nil/1)
    |> case do
      [] -> nil
      vals -> Enum.join(vals, " ")
    end
  end

  # Usually works on a desktop/laptop
  defp vendor, do: read_or_nil("/sys/devices/virtual/dmi/id/chassis_vendor")

  defp product_name, do: read_or_nil("/sys/devices/virtual/dmi/id/product_name")

  # Usually works on a Raspberry Pi
  defp product_model, do: read_or_nil("/proc/device-tree/model")

  defp read_or_nil(path) do
    case File.read(path) do
      {:error, _} -> nil
      {:ok, data} -> handle_binary(data)
    end
  end

  # Reading from /proc and /sys can include characters that aren't printable
  # such as `<<0>>` (null char). Filter them out and make a nice legible string.
  defp handle_binary(data) do
    data
    |> String.codepoints()
    |> Enum.filter(&String.printable?/1)
    |> to_string()
    |> String.trim()
  end
end
