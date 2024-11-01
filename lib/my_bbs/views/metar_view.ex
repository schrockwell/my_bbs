defmodule MyBBS.METARView do
  @behaviour BBS.View

  import BBS.Format
  import BBS.View

  @impl BBS.View
  def mount(_arg, _session, view) do
    view =
      view
      |> clear()
      |> println(ansi([:blue, :bright, "== METAR Lookup =="]))
      |> println("(. to quit)")
      |> println()
      |> icao_prompt()

    {:ok, view}
  end

  defp icao_prompt(view) do
    view
    |> print("LID/ICAO code: ")
    |> prompt(:icao,
      length: 1..4,
      permitted: ~r/[A-Za-z0-9\.]/,
      bell: true,
      format: IO.ANSI.inverse(),
      placeholder: " ",
      transform: &String.upcase/1
    )
  end

  @impl BBS.View
  def handle_prompt(:icao, ".", view) do
    {:noreply, navigate(view, MyBBS.HomeView)}
  end

  def handle_prompt(:icao, <<code::binary-3>>, view) do
    handle_prompt(:icao, "K" <> code, view)
  end

  def handle_prompt(:icao, <<code::binary-4>>, view) do
    url = "https://aviationweather.gov/api/data/metar?ids=#{code}"

    view
    |> println()
    |> print("Retrieving...")

    case Req.get(url) do
      {:ok, %{status: 200, body: ""}} ->
        view |> clear_line() |> println(ansi([:red, "No METAR available"]))

      {:ok, %{status: 200, body: body}} ->
        view |> clear_line() |> println(ansi([:green, String.trim(body)]))

      {:error, _} ->
        view |> clear_line() |> println(ansi([:red, "Error fetching METAR"]))
    end

    {:noreply, icao_prompt(view)}
  end

  def handle_prompt(:icao, _invalid, view) do
    {:noreply,
     view
     |> println()
     |> println(ansi([:red, "Invalid identifier"]))
     |> icao_prompt()}
  end
end
