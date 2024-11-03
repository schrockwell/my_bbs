defmodule MyBBS.WordleView do
  use MyBBS, :view

  alias MyBBS.Wordle

  def mount(_arg, _session, view) do
    view =
      view
      |> assign(:game, Wordle.new())
      |> clear()
      |> draw_words()
      |> draw_alphabet()
      |> prompt_word()

    {:ok, view}
  end

  def handle_prompt(:word, ".", view) do
    {:noreply, navigate(view, MyBBS.HomeView)}
  end

  def handle_prompt(:word, word, view) do
    game = Wordle.guess(view.assigns.game, word)

    view =
      view
      |> assign(:game, game)
      |> draw_words()
      |> draw_alphabet()
      |> prompt_word()

    {:noreply, view}
  end

  def handle_data(_, %{assigns: %{game: %{state: state}}} = view) when state in [:won, :lost] do
    view =
      view
      |> assign(:game, Wordle.new())
      |> clear()
      |> draw_words()
      |> draw_alphabet()
      |> prompt_word()

    {:noreply, view}
  end

  def handle_data(_, view) do
    {:noreply, view}
  end

  defp prompt_word(%{assigns: %{game: %{state: :won}}} = view) do
    print(
      view,
      [
        IO.ANSI.home(),
        IO.ANSI.clear_line(),
        ansi([:bright, :green_background, " YOU WON! :-D "])
      ]
    )
  end

  defp prompt_word(%{assigns: %{game: %{state: :lost, word: word}}} = view) do
    print(
      view,
      [
        IO.ANSI.home(),
        IO.ANSI.clear_line(),
        ansi([:bright, :red_background, " YOU LOST! :'( The answer was '#{word}' "])
      ]
    )
  end

  defp prompt_word(view) do
    view
    |> print(IO.ANSI.home())
    |> print("GUESS: ")
    |> prompt(:word,
      length: 5,
      permitted: ~r/[A-Za-z\.]/,
      bell: true,
      placeholder: " ",
      format: IO.ANSI.reverse(),
      transform: &String.upcase/1
    )
  end

  defp draw_words(view) do
    Enum.map(1..6, fn round ->
      prefix = if(view.assigns.game.round == round, do: " > ", else: "   ")

      line =
        case Enum.at(view.assigns.game.guesses, round - 1) do
          nil ->
            "_ _ _ _ _"

          guess ->
            guess
            |> Enum.map(fn
              {:correct, letter} -> ansi([:green_background, :black, letter])
              {:incorrect, letter} -> letter
              {:partial, letter} -> ansi([:yellow_background, :black, letter])
            end)
            |> Enum.join(" ")
        end

      print(
        view,
        [
          IO.ANSI.cursor(1 + round * 2, 1),
          prefix,
          line
        ]
      )
    end)

    view
  end

  defp draw_alphabet(view) do
    lines = [
      ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M"],
      ["N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    ]

    game = view.assigns.game
    flat_guesses = game.guesses |> List.flatten() |> MapSet.new()

    for {line, index} <- Enum.with_index(lines) do
      output =
        line
        |> Enum.map(fn letter ->
          cond do
            MapSet.member?(flat_guesses, {:correct, letter}) ->
              ansi([:green_background, :black, " #{letter} "])

            MapSet.member?(flat_guesses, {:partial, letter}) ->
              ansi([:yellow_background, :black, " #{letter} "])

            MapSet.member?(flat_guesses, {:incorrect, letter}) ->
              ansi([:inverse, " #{letter} "])

            true ->
              " #{letter} "
          end
        end)
        |> Enum.join(" ")

      print(view, [
        IO.ANSI.cursor(15 + 2 * index, 1),
        output
      ])
    end

    view
  end
end
