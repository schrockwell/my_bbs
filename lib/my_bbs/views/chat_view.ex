defmodule MyBBS.ChatView do
  use MyBBS, :view

  alias MyBBS.Chat

  @impl BBS.View

  def mount(_arg, session, view) do
    view =
      view
      |> clear()
      |> println(ansi([:blue, :bright, "== Chat =="]))
      |> assign(:bell, false)

    view =
      case session do
        %{chat_name: name} -> join_chat(view, name)
        _ -> prompt_name(view)
      end

    {:ok, view}
  end

  @impl BBS.View
  def handle_prompt(:name, name, view) do
    {:noreply, join_chat(view, name)}
  end

  def handle_prompt(:message, cmd, view) when cmd in ["/b", "/bell"] do
    bell = !view.assigns.bell

    view =
      view
      |> assign(:bell, bell)
      |> println()
      |> println("--- Bell is " <> if(bell, do: "ON", else: "OFF"))
      |> prompt_message()

    {:noreply, view}
  end

  def handle_prompt(:message, cmd, view) when cmd in ["/h", "/help"] do
    view =
      view
      |> println()
      |> print_help()
      |> prompt_message()

    {:noreply, view}
  end

  def handle_prompt(:message, cmd, view) when cmd in ["/q", "/quit"] do
    {:noreply, navigate(view, MyBBS.HomeView)}
  end

  def handle_prompt(:message, cmd, view) when cmd in ["/u", "/users"] do
    view =
      view
      |> println()
      |> print_names()
      |> prompt_message()

    {:noreply, view}
  end

  def handle_prompt(:message, "/" <> _, view) do
    view =
      view
      |> println()
      |> println("--- Unknown command")
      |> prompt_message()

    {:noreply, view}
  end

  def handle_prompt(:message, message, view) do
    Chat.push(message)

    {:noreply, view |> clear_line() |> cancel_prompt()}
  end

  @impl BBS.View
  def handle_info({:chat, :joined, name}, view) do
    view =
      view
      |> clear_line()
      |> println("--> #{name} joined.")
      |> maybe_bell()
      |> prompt_message()

    send_update(:header, {:user_count, Chat.count_users()})

    {:noreply, view}
  end

  def handle_info({:chat, :message, name, message}, view) do
    view =
      view
      |> clear_line()
      |> println(ansi([:bright, "#{name}: #{message}"]))
      |> maybe_bell()
      |> prompt_message()

    {:noreply, view}
  end

  def handle_info({:chat, :left, name}, view) do
    view =
      view
      |> clear_line()
      |> println("<-- #{name} left.")
      |> maybe_bell()
      |> prompt_message()

    send_update(:header, {:user_count, Chat.count_users()})

    {:noreply, view}
  end

  defp prompt_name(view) do
    view
    |> println()
    |> print("Name (3-16 chars): ")
    |> prompt(:name,
      length: 3..16,
      permitted: ~r/[A-Za-z0-9_\-]/,
      bell: true,
      format: IO.ANSI.inverse(),
      placeholder: " "
    )
  end

  defp prompt_message(view) do
    view
    |> print("#{view.assigns.name}: ")
    |> prompt(:message,
      length: 1..140,
      permitted: ~r/./
    )
  end

  defp print_names(view) do
    names = Chat.list_users()
    word = if(length(names) == 1, do: "user", else: "users")

    println(view, "#{length(names)} #{word} online: " <> Enum.join(names, ", "))
  end

  def print_help(view) do
    view
    |> println("== Commands ==")
    |> println("/b /bell     Toggle bell")
    |> println("/h /help     Show this message")
    |> println("/q /quit     Quit the chat")
    |> println("/u /users    List users")
    |> println()
  end

  defp maybe_bell(view) do
    if view.assigns.bell do
      print(view, "\a")
    end

    view
  end

  defp join_chat(view, name) do
    case Chat.join(name) do
      :ok ->
        view
        |> assign(:name, name)
        |> put_session(:chat_name, name)
        |> clear()
        |> print("\e[2;25r")
        |> component(:header, MyBBS.ChatHeader, {1, 1})
        # Set scroll region
        |> print(IO.ANSI.cursor(2, 1))
        |> println("Joined chat as #{name}.")
        |> print_help()
        |> print_names()
        |> prompt_message()

      {:error, :name_taken} ->
        view
        |> clear_line()
        |> println("Name taken. Try again.")
        |> prompt_name()
    end
  end
end
