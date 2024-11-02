defmodule MyBBS.ChatServer do
  use GenServer

  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl GenServer
  def init(_arg) do
    {:ok, %{members: %{}}}
  end

  @impl GenServer
  def handle_call({:join, name}, {pid, _}, state) do
    if name in names(state) do
      {:reply, {:error, :name_taken}, state}
    else
      Logger.info("[Chat] #{name} joined")

      {:reply, :ok,
       state
       |> add_member(name, pid)
       |> broadcast({:chat, :joined, name})}
    end
  end

  def handle_call(:list_users, _from, state) do
    {:reply, names(state), state}
  end

  def handle_call(:count_users, _from, state) do
    {:reply, map_size(state.members), state}
  end

  @impl GenServer
  def handle_cast({:push, message, from}, state) do
    if member = state.members[from] do
      broadcast(state, {:chat, :message, member.name, message})
    end

    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:DOWN, _, :process, pid, _}, state) do
    member = state.members[pid]
    broadcast(state, {:chat, :left, member.name})
    Logger.info("[Chat] #{member.name} left")

    members = Map.delete(state.members, pid)
    {:noreply, %{state | members: members}}
  end

  defp add_member(state, name, pid) do
    monitor = Process.monitor(pid)
    member = %{name: name, monitor: monitor}
    put_in(state.members[pid], member)
  end

  defp names(state) do
    state.members
    |> Enum.map(fn {_, m} -> m.name end)
    |> Enum.sort()
  end

  defp broadcast(state, message) do
    state.members
    |> Map.keys()
    |> Enum.each(fn pid -> send(pid, message) end)

    state
  end
end
