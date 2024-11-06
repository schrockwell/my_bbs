defmodule MyBBS.Dictionary do
  @dictionaries %{
    wordle_answers:
      :my_bbs
      |> Application.app_dir("priv")
      |> Path.join("dictionary.txt")
      |> File.read!()
      |> String.split("\n")
      |> Enum.filter(&(String.length(&1) == 5 and not String.ends_with?(&1, "S")))
      |> MapSet.new(),
    wordle_guesses:
      :my_bbs
      |> Application.app_dir("priv")
      |> Path.join("dictionary.txt")
      |> File.read!()
      |> String.split("\n")
      |> Enum.filter(&(String.length(&1) == 5))
      |> MapSet.new(),
    hangman:
      :my_bbs
      |> Application.app_dir("priv")
      |> Path.join("dictionary.txt")
      |> File.read!()
      |> String.split("\n")
      |> Enum.filter(&(String.length(&1) >= 4))
      |> MapSet.new()
  }

  def random(dictionary) do
    Enum.random(@dictionaries[dictionary])
  end

  def contains?(dictionary, word) do
    MapSet.member?(@dictionaries[dictionary], word)
  end
end
