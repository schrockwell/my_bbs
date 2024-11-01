defmodule MyBBS.HomeView do
  @behaviour BBS.View

  import BBS.View

  def mount(_arg, _session, view) do
    view =
      view
      |> clear()
      |> println("*** WELCOME TO NETSTALGIA ***")
      |> println()
      |> println("Select an option:")
      |> println()
      |> println("C) Chat")
      |> println("M) METAR Lookup")
      |> println(".) Disconnect")
      |> println()
      |> print("CHOICE: ")
      |> prompt(:choice,
        length: 1,
        permitted: ~r/[MmCc\.]/,
        bell: true,
        format: IO.ANSI.inverse(),
        placeholder: " ",
        immediate: true
      )
      |> component(:clock, MyBBS.ClockComponent, {1, 58})

    {:ok, view}
  end

  def handle_prompt(:choice, c, view) when c in ["c", "C"] do
    {:noreply, navigate(view, MyBBS.ChatView)}
  end

  def handle_prompt(:choice, m, view) when m in ["m", "M"] do
    {:noreply, navigate(view, MyBBS.METARView)}
  end

  def handle_prompt(:choice, ".", view) do
    view =
      view
      |> clear()
      |> println("Thanks for visiting NETSTALGIA! _o>")
      |> disconnect()

    {:noreply, view}
  end
end
