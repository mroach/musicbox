defmodule RFID.Monitor do
  @moduledoc """
  This server opens up the serial connection to the RFID reader and watches
  for card scanned events.
  Currently this is done in a loop, but eventually the goal is to have interrupts.

  When a card is scanned, a the `handler` will be called.
  Card presence is checked every 100ms (the tag scanning itself takes time too).
  """

  use GenServer
  alias Circuits.SPI
  require Logger

  defmodule Scan do
    @enforce_keys [:timestamp, :tag_id]
    defstruct [:timestamp, :tag_id]

    def new(tag_id) do
      %__MODULE__{tag_id: tag_id, timestamp: :os.system_time(:millisecond)}
    end
  end

  defmodule State do
    defstruct [:spi, :handler, :last_scan]
  end

  @card_check_every_ms 100

  # Minimum time that the same card has to be away from the reader in order to
  # trigger a repeat "card found" event. This prevents multiple notifications
  # when a card is sitting on the reader or the same card is tapped many times.
  @repeat_delay 1000

  def start_link([args]) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc """
  Reference to the SPI to manually interact with the reader via `RC522`
  """
  def spi, do: GenServer.call(__MODULE__, :spi)

  @impl true
  def init(opts) do
    device = opts[:device] || default_spi_bus()
    handler = opts[:handler]

    Logger.debug "Connecting to RC522 device on #{device}"
    {:ok, spi} = SPI.open(device)
    RC522.initialize(spi)

    hwver = RC522.hardware_version(spi)
    Logger.info "Connected to #{hwver.chip_type} reader version #{hwver.version}"

    schedule_card_check()

    {:ok, %State{spi: spi, handler: handler}}
  end

  @impl true
  def terminate(_reason, state) do
    SPI.close(state.spi)
  end

  @impl true
  def handle_call(:spi, _from, %State{spi: spi} = state), do: {:reply, spi, state}

  def handle_call(:read_tag_id, _from, %{spi: spi} = state) do
    {:ok, data} = RC522.read_tag_id(spi)
    tag_id = RC522.card_id_to_number(data)
    {:reply, tag_id, state}
  end

  @impl true
  def handle_info(:card_check, %State{spi: spi} = state) do
    {:ok, data} = RC522.read_tag_id(spi)

    state =
      case process_tag_id(data) do
        {:ok, tag_id} ->
          maybe_notify(tag_id, state)
          Map.put(state, :last_scan, Scan.new(tag_id))
        {:error, _} ->
          state
      end

    schedule_card_check()

    {:noreply, state}
  end

  defp maybe_notify(tag_id, %State{handler: handler, last_scan: last_scan}) do
    case notify?(tag_id, last_scan) do
      true ->
        apply(handler, :tag_scanned, [tag_id])
        :ok
      _ ->
        :noop
    end
  end

  # only notify if the card ID changed or the repeat delay elapsed
  defp notify?(this_tag_id, %Scan{tag_id: last_tag_id, timestamp: timestamp})
    when this_tag_id == last_tag_id do

    :os.system_time(:millisecond) > (timestamp + @repeat_delay)
  end
  defp notify?(_, _), do: true

  # if the response is a list with length of 5, that'll be the card ID
  # otherwise, no card is present or there was a problem reading it
  defp process_tag_id(data) when is_list(data) and length(data) == 5 do
    {:ok, RC522.card_id_to_number(data)}
  end
  defp process_tag_id(_), do: {:error, :nocard}

  defp default_spi_bus, do: SPI.bus_names |> Enum.at(0)

  defp schedule_card_check(delay \\ @card_check_every_ms) do
    Process.send_after(self(), :card_check, delay)
  end
end
