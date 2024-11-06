defmodule MyBBS.Hangman do
  defstruct word: "hangman", guesses: MapSet.new(), state: :playing, remaining: 7

  alias MyBBS.Dictionary

  def new do
    %MyBBS.Hangman{word: String.upcase(Dictionary.random(:hangman))}
  end

  def guess(%{state: :playing} = game, letter) do
    letter = String.upcase(letter)

    if MapSet.member?(game.guesses, letter) do
      game
    else
      guesses = MapSet.put(game.guesses, letter)
      remaining = game.remaining - if(String.contains?(game.word, letter), do: 0, else: 1)

      state =
        cond do
          remaining == 0 ->
            :lost

          MapSet.new(String.graphemes(game.word)) |> MapSet.subset?(guesses) ->
            :won

          true ->
            :playing
        end

      %MyBBS.Hangman{game | guesses: guesses, remaining: remaining, state: state}
    end
  end
end
