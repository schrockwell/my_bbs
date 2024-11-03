defmodule MyBBS.WordleView do
  use MyBBS, :view

  alias MyBBS.Wordle

  def mount(_arg, _session, view) do
    view =
      view
      |> assign(:game, Wordle.new())
      |> assign(:input_index, 0)
      |> assign(:input, ["", "", "", "", ""])
      |> clear()
      |> draw_words()
      |> draw_alphabet()
      |> move_cursor()

    {:ok, view}
  end

  def handle_data(".", view) do
    {:noreply, navigate(view, MyBBS.HomeView)}
  end

  def handle_data({:cursor_right, [count]}, %{assigns: %{game: %{state: :playing}}} = view) do
    next_index = min(4, view.assigns.input_index + count)

    view =
      view
      |> assign(:input_index, next_index)
      |> move_cursor()

    {:noreply, view}
  end

  def handle_data({:cursor_left, [count]}, %{assigns: %{game: %{state: :playing}}} = view) do
    next_index = max(0, view.assigns.input_index - count)

    view =
      view
      |> assign(:input_index, next_index)
      |> move_cursor()

    {:noreply, view}
  end

  def handle_data(<<ascii>> = letter, %{assigns: %{game: %{state: :playing}}} = view)
      when ascii in ?A..?Z or ascii in ?a..?z do
    letter = String.upcase(letter)
    guesses = List.replace_at(view.assigns.input, view.assigns.input_index, letter)
    next_index = min(4, view.assigns.input_index + 1)

    view =
      view
      |> assign(:input, guesses)
      |> assign(:input_index, next_index)
      |> print(letter)
      |> move_cursor()

    {:noreply, view}
  end

  def handle_data("\b", %{assigns: %{game: %{state: :playing}}} = view) do
    bs_index =
      if view.assigns.input_index > 0 &&
           Enum.at(view.assigns.input, view.assigns.input_index) == "" do
        print(view, IO.ANSI.cursor_left(2))
        view.assigns.input_index - 1
      else
        view.assigns.input_index
      end

    guesses = List.replace_at(view.assigns.input, bs_index, "")
    next_index = max(0, view.assigns.input_index - 1)

    view =
      view
      |> assign(:input, guesses)
      |> assign(:input_index, next_index)
      |> print("_")
      |> move_cursor()

    {:noreply, view}
  end

  def handle_data("\r", %{assigns: %{game: %{state: :playing}}} = view) do
    word = Enum.join(view.assigns.input)
    game = Wordle.guess(view.assigns.game, word)

    view =
      view
      |> assign(:game, game)
      |> assign(:input, ["", "", "", "", ""])
      |> assign(:input_index, 0)
      |> draw_words()
      |> draw_alphabet()
      |> draw_result()
      |> move_cursor()

    {:noreply, view}
  end

  def handle_data(_, %{assigns: %{game: %{state: state}}} = view) when state in [:won, :lost] do
    view =
      view
      |> assign(:game, Wordle.new())
      |> assign(:input, ["", "", "", "", ""])
      |> assign(:input_index, 0)
      |> clear()
      |> draw_words()
      |> draw_alphabet()
      |> move_cursor()

    {:noreply, view}
  end

  def handle_data(_, view) do
    {:noreply, view}
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

  defp draw_result(%{assigns: %{game: %{state: :lost, word: word}}} = view) do
    print(
      view,
      [
        IO.ANSI.home(),
        IO.ANSI.clear_line(),
        ansi([:bright, :red_background, " YOU LOST! :'( The answer was '#{word}' "])
      ]
    )
  end

  defp draw_result(view) do
    view
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

  defp move_cursor(%{assigns: %{game: %{state: :playing}}} = view) do
    line = 1 + view.assigns.game.round * 2
    col = 4 + view.assigns.input_index * 2
    print(view, IO.ANSI.cursor(line, col))
  end

  defp move_cursor(view) do
    print(view, IO.ANSI.home())
  end
end
