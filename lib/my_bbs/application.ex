defmodule MyBBS.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MyBBS.Chat,
      BBS.Supervisor,
      {BBS.Endpoint,
       initial_view: MyBBS.HomeView, port: String.to_integer(System.get_env("PORT", "8080"))}
      # Starts a worker by calling: MyBBS.Worker.start_link(arg)
      # {MyBBS.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MyBBS.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
