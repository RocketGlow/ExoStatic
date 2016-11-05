defmodule Exostatic do

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      worker(Agent, [fn -> %{} end, [name: Exostatic.BuildData]], id: "exostatic_bd"),
      worker(Agent, [fn -> [] end, [name: Exostatic.PostInfoStorage]], id: "exostatic_pis")
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exostatic.Supervisor]
    {:ok, _pid} = Supervisor.start_link(children, opts)

  end

end
