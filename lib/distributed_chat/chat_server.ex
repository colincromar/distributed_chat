defmodule DistributedChat.ChatServer do
  use GenServer

  # Public API

  @doc """
  Starts the ChatServer process and links it to the current process.

  - `start_link/1` is the typical OTP convention. The `link` part means
    if this GenServer crashes, it will bring down the caller (unless
    there's a Supervisor in between).
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :no_state_yet, opts)
  end

  def broadcast_message(server, message) do
    GenServer.cast(server, {:broadcast, message})
  end

  def get_messages(server) do
    GenServer.call(server, :get_messages)
  end

  # Callbacks
  @impl true
  def init(_initial_arg) do
    case Node.list() do
      [] ->
        # No nodes available, start empty
        {:ok, []}

      [primary | _rest] ->
        # Connect to the first node in the list and sync state
        new_messages = GenServer.call({__MODULE__, primary}, :get_messages)
        {:ok, new_messages}
    end
  end

  @impl true
  def handle_call(:get_messages, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:broadcast, message}, state) do
    new_state = state ++ [message]

    Node.list()
    |> Enum.each(fn other_node ->
      GenServer.cast({__MODULE__, other_node}, {:replicate, message})
    end)

    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:replicate, message}, state) do
    # Don’t replicate further or we’d get an infinite loop
    # TODO - ask if this is outdated with enum.each
    new_state = state ++ [message]
    {:noreply, new_state}
  end
end
