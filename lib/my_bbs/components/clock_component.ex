defmodule MyBBS.ClockComponent do
  use MyBBS, :component

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
  def render(view) do
    print(
      view,
      ansi([
        :yellow,
        :bright,
        Calendar.strftime(view.assigns.now, "%Y-%m-%d %H:%M:%S UTC")
      ])
    )
  end
end
