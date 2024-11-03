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
    guess
    |> String.graphemes()
    |> Enum.zip(String.graphemes(answer))
    |> Enum.map(fn
      {letter, letter} ->
        {:correct, letter}

      {letter, _} ->
        if String.contains?(answer, letter) do
          {:partial, letter}
        else
          {:incorrect, letter}
        end
    end)
  end
end
