# DistributedChat

A scalable distributed chat system implemented in Elixir and built upon the OTP (Open Telecom Platform) framework.
This is mainly an educational project to demonstrate the principles of distributed systems in Elixir.

## Local Setup

### Launching IEx

To initiate an interactive Elixir session with the application loaded:

```sh
iex -S mix
```

### Verifying the ChatServer

The application launches a supervised `ChatServer` by default.

You can interact with it using the following commands:

```elixir
DistributedChat.ChatServer.broadcast_message(DistributedChat.ChatServer, "Hello from local node!")
DistributedChat.ChatServer.get_messages(DistributedChat.ChatServer)
# => ["Hello from local node!"]
```

### Crash Recovery

The `ChatServer` operates under supervision. If a process crash occurs, the supervisor will automatically restart it to restore functionality.

## Dynamic Chat Rooms

This project demonstrates **Dynamic Supervision** using `ChatRoomSupervisor` and an **Elixir Registry**, allowing for the runtime instantiation of multiple independent chat rooms, each managed by a dedicated `ChatServer`.

### Creating a New Chat Room

```elixir
DistributedChat.start_chat_room("general")
```

### Broadcasting a Message Within a Room

```elixir
GenServer.cast({:via, Registry, {DistributedChat.Registry, "general"}}, {:broadcast, "Hey everyone in general!"})
```

### Retrieving Messages from a Room

```elixir
GenServer.call({:via, Registry, {DistributedChat.Registry, "general"}}, :get_messages)
# => ["Hey everyone in general!"]
```

Each room operates as an independent `GenServer` under a dynamic supervisor. This ensures state isolation and fault tolerance, preventing failures in one room from impacting others.

## Running on Distributed Nodes

Elixir’s built-in distributed computing capabilities enable clustering multiple nodes seamlessly. You can run multiple `IEx` sessions with distinct node identifiers and establish connections between them.

### Starting Nodes

#### Terminal 1
```sh
iex --sname node1 -S mix
```

#### Terminal 2
```sh
iex --sname node2 -S mix
```

### Establishing a Connection

From `node1`, connect to `node2`:

```elixir
Node.connect(:"node2@YOUR_MACHINE_NAME")
# => true
```

### Verifying Connection Status

```elixir
Node.list()
# => [:"node2@YOUR_MACHINE_NAME"]
```

Once connected, the nodes form a distributed cluster.

## Cross-Node Message Replication

### Broadcasting from Node 1

```elixir
DistributedChat.ChatServer.broadcast_message(DistributedChat.ChatServer, "Hello from node1!")
```

### Retrieving Messages from Node 2

```elixir
DistributedChat.ChatServer.get_messages(DistributedChat.ChatServer)
# => ["Hello from node1!"]
```

### Implementation Details

Each `ChatServer`’s `handle_cast({:broadcast, message}, state)` function also triggers message replication across all connected nodes:

```elixir
Node.list()
|> Enum.each(fn other_node ->
  GenServer.cast({__MODULE__, other_node}, {:replicate, message})
end)
```

The recipient node’s `handle_cast({:replicate, message}, state)` appends the incoming message to its local state, thereby enabling simplistic but effective replication.

## Handling Node Failures and Synchronization

When a node disconnects, it may miss broadcasted messages. One approach to mitigating message loss is synchronizing state from a designated primary node upon startup:

```elixir
def init(_args) do
  case Node.list() do
    [] ->
      {:ok, []}

    [primary_node | _] ->
      messages = GenServer.call({__MODULE__, primary_node}, :get_messages)
      {:ok, messages}
  end
end
```

While this provides a basic synchronization mechanism, production-ready solutions typically leverage **CRDTs (Conflict-Free Replicated Data Types)** or databases with built-in replication for consistency and fault tolerance.

## License

This project serves as an educational resource. Feel free to use, modify, and distribute the code as needed.

## Contributing

If you encounter issues or have suggestions for improvements, please open an issue or submit a pull request. Contributions are always welcome!

## Acknowledgments

Thank you for exploring this project! We hope it provides valuable insights into distributed systems in Elixir. Happy coding!
