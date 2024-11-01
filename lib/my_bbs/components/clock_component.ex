defmodule MyBBS.ClockComponent do
  use BBS.Component

  import BBS.View

  @impl BBS.Component
  def mount(_, view) do
    view = assign(view, :now, DateTime.utc_now())
    send_update_after(view.id, :tick, 1000)
    {:ok, view}
  end

  @impl BBS.Component
  def update(:tick, view) do
    send_update_after(view.id, :tick, 1000)
    {:ok, assign(view, :now, DateTime.utc_now())}
  end

  @impl BBS.Component
  def render(assigns) do
    IO.ANSI.format([
      :yellow,
      :bright,
      Calendar.strftime(assigns.now, "%Y-%m-%d %H:%M:%S UTC")
    ])
  end
end
