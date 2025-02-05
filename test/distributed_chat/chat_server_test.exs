defmodule DistributedChat.ChatServerTest do
  use ExUnit.Case, async: true

  describe "unsupervised" do
    test "broadcast_message appends a message to the state" do
      {:ok, pid} = DistributedChat.ChatServer.start_link([])

      DistributedChat.ChatServer.broadcast_message(pid, "Hello!")
      assert DistributedChat.ChatServer.get_messages(pid) == ["Hello!"]
    end
  end

  describe "supervised" do
    setup do
      {:ok, pid} = start_supervised(DistributedChat.ChatServer)
      [server_pid: pid]
    end

    test "stores messages", %{server_pid: pid} do
      DistributedChat.ChatServer.broadcast_message(pid, "Hi!")
      assert DistributedChat.ChatServer.get_messages(pid) == ["Hi!"]
    end
  end
end
