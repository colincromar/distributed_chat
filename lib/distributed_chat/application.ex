defmodule DistributedChat.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: DistributedChat.Registry},
      {DistributedChat.ChatServer, name: DistributedChat.ChatServer},
      {DistributedChat.ChatRoomSupervisor, []}
    ]

    opts = [strategy: :one_for_one, name: DistributedChat.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
