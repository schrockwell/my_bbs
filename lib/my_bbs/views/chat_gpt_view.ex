defmodule MyBBS.ChatGPTView do
  use MyBBS, :view

  @impl BBS.View
  def mount(_arg, _session, view) do
    view =
      view
      |> assign(:messages, [
        %{
          role: "system",
          content:
            "You are a helpful assistant. Only respond using characters in the ASCII character set. Do not respond with UTF-8 characters."
        }
      ])
      |> clear()
      |> println("Welcome to ChatGPT. Type \".\" to exit.")
      |> print_prompt()

    {:ok, view}
  end

  @impl BBS.View
  def handle_prompt(:query, ".", view) do
    {:noreply, navigate(view, MyBBS.HomeView)}
  end

  def handle_prompt(:query, query, view) do
    println(view)

    view = append_message(view, "user", query)

    content =
      view.assigns.messages
      |> MyBBS.OpenAI.stream_chat()
      |> Enum.map(fn
        %{"choices" => [%{"delta" => %{"content" => content}}]} ->
          content = String.replace(content, "\n", "\r\n")
          print(view, content)
          content

        _other ->
          nil
      end)

    view = append_message(view, "assistant", Enum.join(content))

    {:noreply, print_prompt(view)}
  end

  defp print_prompt(view) do
    view
    |> println()
    |> print("> ")
    |> prompt(:query, permitted: ~r/./)
  end

  defp append_message(view, role, content) do
    assign(view, :messages, view.assigns.messages ++ [%{role: role, content: content}])
  end
end
