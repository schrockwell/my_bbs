defmodule MyBBS.Wordle do
  defstruct word: nil, guesses: [], state: :playing, round: 1

  @words :my_bbs
         |> Application.app_dir("priv")
         |> Path.join("hangman.txt")
         |> File.read!()
         |> String.split("\n")
         |> Enum.filter(&(String.length(&1) == 5))

  defp random_word do
    Enum.random(@words)
  end

  def new do
    %MyBBS.Wordle{word: String.upcase(random_word())}
  end

  def guess(%{state: :playing} = game, <<_::binary-5>> = word) do
    word = String.upcase(word)
    guesses = game.guesses ++ [analyze_guess(game.word, word)]

    state =
      cond do
        word == game.word -> :won
        game.round == 6 -> :lost
        true -> :playing
      end

    round = game.round + 1

    %{game | guesses: guesses, state: state, round: round}
  end

  def guess(game, _word), do: game

  defp analyze_guess(answer, guess) do
    histogram = answer |> String.graphemes() |> Enum.frequencies()

    # Get a histogram of the incorrect guesses remaining
    incorrect_hist =
      String.graphemes(guess)
      |> Enum.zip(String.graphemes(answer))
      |> Enum.reduce(histogram, fn
        {correct, correct}, hist -> Map.update!(hist, correct, &(&1 - 1))
        {_guess, _answer}, hist -> hist
      end)

    analyze_guess(String.graphemes(guess), String.graphemes(answer), incorrect_hist, [])
  end

  defp analyze_guess([correct | rest_guest], [correct | rest_answer], histogram, acc) do
    analyze_guess(rest_guest, rest_answer, histogram, [{:correct, correct} | acc])
  end

  defp analyze_guess([guess | rest_guest], [_answer | rest_answer], histogram, acc) do
    if Map.get(histogram, guess, 0) > 0 do
      next_hist = Map.update!(histogram, guess, &(&1 - 1))
      analyze_guess(rest_guest, rest_answer, next_hist, [{:partial, guess} | acc])
    else
      analyze_guess(rest_guest, rest_answer, histogram, [{:incorrect, guess} | acc])
    end
  end

  defp analyze_guess([], [], _, acc) do
    Enum.reverse(acc)
  end
end
