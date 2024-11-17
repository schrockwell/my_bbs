defmodule MyBBS.HomeView do
  use MyBBS, :view

  def mount(_arg, _session, view) do
    view =
      view
      |> clear()
      |> println("*** WELCOME TO NETSTALGIA ***")
      |> println()
      |> println("Select an option:")
      |> println()
      |> println("C) Chat")
      |> println("G) ChatGPT")
      |> println("H) Hangman")
      |> println("M) METAR Lookup")
      |> println("W) Wordle")
      |> println(".) Disconnect")
      |> println()
      |> print("CHOICE: ")
      |> prompt(:choice,
        length: 1,
        permitted: ~r/[MmCcGgHhWw\.]/,
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

  def handle_prompt(:choice, g, view) when g in ["g", "G"] do
    {:noreply, navigate(view, MyBBS.ChatGPTView)}
  end

  def handle_prompt(:choice, h, view) when h in ["h", "H"] do
    {:noreply, navigate(view, MyBBS.HangmanView)}
  end

  def handle_prompt(:choice, m, view) when m in ["m", "M"] do
    {:noreply, navigate(view, MyBBS.METARView)}
  end

  def handle_prompt(:choice, w, view) when w in ["w", "W"] do
    {:noreply, navigate(view, MyBBS.WordleView)}
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
