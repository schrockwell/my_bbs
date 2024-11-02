defmodule MyBBS.ChatHeader do
  use MyBBS, :component

  alias MyBBS.Chat

  def mount(_, view) do
    view =
      view
      |> assign(:user_count, Chat.count_users())
      |> assign(:now, now())
      |> assign(:initial, true)

    send_update_after(view.id, :tick, 1000)

    {:ok, view}
  end

  def update(:tick, view) do
    send_update_after(view.id, :tick, 1000)
    {:ok, assign(view, now: now(), initial: false)}
  end

  def update({:user_count, count}, view) do
    {:ok, assign(view, user_count: count)}
  end

  def render(view) do
    suffix = if(view.assigns.user_count == 1, do: "user ", else: "users")
    users = "#{view.assigns.user_count} #{suffix}"

    if view.assigns.initial do
      print(view, [ansi([:blue_background, String.duplicate(" ", 80)])])
    end

    print(
      view,
      [
        IO.ANSI.cursor(1, 1),
        ansi_fragment([
          :blue_background,
          :bright,
          :yellow,
          " #{users}"
        ]),
        IO.ANSI.cursor(1, 80 - 12),
        view.assigns.now,
        IO.ANSI.reset()
      ]
    )
  end

  defp now do
    Calendar.strftime(DateTime.utc_now(), "%H:%M:%S UTC")
  end
end
