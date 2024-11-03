defmodule MyBBS.HangmanView do
  use MyBBS, :view

  alias MyBBS.Hangman

  @art %{
    7 => """
      +---+
      |   |
          |
          |
          |
          |
      =========
    """,
    6 => """
      +---+
      |   |
      O   |
          |
          |
          |
      =========
    """,
    5 => """
      +---+
      |   |
      O   |
      |   |
          |
          |
      =========
    """,
    4 => """
      +---+
      |   |
      O   |
     /|   |
          |
          |
      =========
    """,
    3 => """
      +---+
      |   |
      O   |
     /|\\  |
          |
          |
      =========
    """,
    2 => """
      +---+
      |   |
      O   |
     /|\\  |
     /    |
          |
      =========
    """,
    1 => """
      +---+
      |   |
      O   |
     /|\\  |
     / \\  |
          |
      =========
    """,
    0 => """
      +---+
      |   |
      X   |
     /|\\  |
     / \\  |
          |
      =========
    """
  }

  def mount(_params, _session, view) do
    view =
      view
      |> clear()
      |> assign(:game, MyBBS.Hangman.new())
      |> redraw()

    {:ok, view}
  end

  def handle_prompt(:guess, ".", view) do
    {:noreply, navigate(view, MyBBS.HomeView)}
  end

  def handle_prompt(:guess, letter, view) do
    game = Hangman.guess(view.assigns.game, letter)

    view =
      view
      |> assign(:game, game)
      |> redraw()

    {:noreply, view}
  end

  def handle_data(_, %{assigns: %{game: %{state: state}}} = view) when state in [:won, :lost] do
    view =
      view
      |> clear()
      |> assign(:game, MyBBS.Hangman.new())
      |> redraw()

    {:noreply, view}
  end

  def handle_data(_, view) do
    {:noreply, view}
  end

  defp prompt_guess(%{assigns: %{game: %{state: :playing}}} = view) do
    view
    |> print(IO.ANSI.home() <> "Guess (#{view.assigns.game.remaining} remaining, . to exit): ")
    |> prompt(:guess, length: 1, permitted: ~r/[A-Z\.]/i, immediate: true)
  end

  defp prompt_guess(view), do: view

  defp draw_word(view) do
    output =
      view.assigns.game.word
      |> String.graphemes()
      |> Enum.map(fn letter ->
        cond do
          MapSet.member?(view.assigns.game.guesses, letter) ->
            letter

          view.assigns.game.state == :lost ->
            ansi([:red, letter])

          true ->
            "_"
        end
      end)
      |> Enum.join(" ")

    print(view, IO.ANSI.cursor(3, 2) <> output)
  end

  defp draw_alphabet(%{assigns: %{game: game}} = view) do
    lines = [
      ["A", "B", "C", "D", "E", "F", "G", "H", "I"],
      ["J", "K", "L", "M", "N", "O", "P", "Q", "R"],
      ["S", "T", "U", "V", "W", "X", "Y", "Z"]
    ]

    for {line, index} <- Enum.with_index(lines) do
      output =
        line
        |> Enum.map(fn letter ->
          cond do
            MapSet.member?(game.guesses, letter) && String.contains?(game.word, letter) ->
              ansi([:reverse, :green_background, " #{letter} "])

            MapSet.member?(game.guesses, letter) && not String.contains?(game.word, letter) ->
              ansi([:reverse, :red_background, " #{letter} "])

            true ->
              " #{letter} "
          end
        end)
        |> Enum.join(" ")

      print(view, IO.ANSI.cursor(5 + 2 * index, 2) <> output)
    end

    view
  end

  defp draw_hangman(view) do
    print(
      view,
      IO.ANSI.cursor(12, 1) <>
        String.replace(Map.get(@art, view.assigns.game.remaining), "\n", "\n\r")
    )
  end

  defp draw_result(%{assigns: %{game: %{state: :won}}} = view) do
    print(
      view,
      [
        IO.ANSI.home(),
        IO.ANSI.clear_line(),
        ansi([:bright, :green_background, " YOU WON! :-D "])
      ]
    )
  end

  defp draw_result(%{assigns: %{game: %{state: :lost}}} = view) do
    print(
      view,
      [
        IO.ANSI.home(),
        IO.ANSI.clear_line(),
        ansi([:bright, :red_background, " YOU LOST! :'( "])
      ]
    )
  end

  defp draw_result(view) do
    view
  end

  def redraw(view) do
    view
    |> draw_word()
    |> draw_alphabet()
    |> draw_hangman()
    |> draw_result()
    |> prompt_guess()
  end
end
