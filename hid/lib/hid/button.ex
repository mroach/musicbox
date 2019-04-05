defmodule HID.Button do
  defmodule State do
    defstruct events: [], gpio_pid: nil
  end

  defmodule Event do
    defstruct [:direction, :timestamp, :duration]
  end

  defmacro __using__(args) do
    quote do
      use GenServer
      require Logger
      import HID.Button
      alias Circuits.GPIO

      def pin_id, do: unquote(args[:pin_id])

      def pull_mode, do: unquote(args[:pull_mode] || :pullup)

      @button_down unquote(if args[:pull_mode] == :pulldown, do: 1, else: 0)
      @button_up unquote(if args[:pull_mode] == :pulldown, do: 0, else: 1)

      def start_link(args) do
        GenServer.start_link(__MODULE__, args, name: __MODULE__)
      end

      @doc """
      Get all button events since the server started. List of simple maps. The list
      has the most recent events first to simplify retrieval of most recent events.
      """
      def event_history, do: GenServer.call(__MODULE__, :event_history)

      @doc """
      Get the `PID` for the `Circuits.GPIO` process managing the GPIO pin.
      This can be useful for debugging and manually working with the GPIO process.
      """
      def gpio_pid, do: GenServer.call(__MODULE__, :gpio_pid)

      @impl true
      def init(_opts) do
        with {:ok, gpio} <- GPIO.open(pin_id(), :input, pull_mode: pull_mode()),
             :ok <- GPIO.set_interrupts(gpio, :both, receiver: __MODULE__)
        do
          Logger.info "Started monitoring GPIO pin #{pin_id()}"

          state = %State{gpio_pid: gpio}
          {:ok, state}
        else
          error -> {:error, error}
        end
      end

      # An event is fired immediately when the server starts with the current
      # state of the button. This serves as the first event in the list, but
      # it's not a "real" interaction with the button. For this event, the duration
      # will be `0` and should be ignored. Otherwise all implementations would
      # have to check the `duration` in the event and ignore `0`.
      def dispatch_event(%{duration: 0}), do: nil
      def dispatch_event(%{direction: :down} = event) do
        Kernel.apply(__MODULE__, :pressed, [event])
      end
      def dispatch_event(%{direction: :up} = event) do
        Kernel.apply(__MODULE__, :released, [event])
      end

      @impl true
      def handle_info({:circuits_gpio, pin_id, _timestamp, value}, state) do
        # use system time as the timestamp rather than kernel time. easier to deal with
        timestamp = :os.system_time(:millisecond)

        duration = case List.first(state.events) do
          nil -> 0
          %Event{timestamp: last_timestamp} -> timestamp - last_timestamp
        end

        direction = case value do
          @button_down -> :down
          @button_up -> :up
        end

        event = %Event{
          direction: direction,
          timestamp: timestamp,
          duration: duration
        }

        dispatch_event(event)

        state = %{state | events: [event | state.events]}

        {:noreply, state}
      end

      @impl true
      def handle_call(:event_history, _from, %{events: history} = state) do
        {:reply, history, state}
      end

      @impl true
      def handle_call(:gpio_pid, _from, %{gpio_pid: pid} = state) do
        {:reply, pid, state}
      end
    end
  end
end
