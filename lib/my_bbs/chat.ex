defmodule MyBBS.Chat do
  @server MyBBS.ChatServer

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {@server, :start_link, []}
    }
  end

  def join(name) do
    GenServer.call(@server, {:join, name})
  end

  def push(message) do
    GenServer.cast(@server, {:push, message, self()})
  end

  def list_users do
    GenServer.call(@server, :list_users)
  end

  def count_users do
    GenServer.call(@server, :count_users)
  end
end
