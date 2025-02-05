defmodule DistributedChat do
  @moduledoc """
  Documentation for `DistributedChat`.
  """
  def start_chat_room(room_id) do
    spec = %{
      id: DistributedChat.ChatServer,
      start: {DistributedChat.ChatServer, :start_link, [[name: via_room_id(room_id)]]}
    }

    DynamicSupervisor.start_child(DistributedChat.ChatRoomSupervisor, spec)
  end

  def via_room_id(room_id) do
    {:via, Registry, {DistributedChat.Registry, room_id}}
  end
end
