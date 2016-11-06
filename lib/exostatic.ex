defmodule Exostatic do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      worker(Agent, [fn -> %{} end, [name: Exostatic.BuildData]], id: "exostatic_bd"),
      worker(Agent, [fn -> [] end, [name: Exostatic.PostInfoStorage]], id: "exostatic_pis")
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exostatic.Supervisor]

    {:ok, _pid} = Supervisor.start_link children, opts
  end

  def init_data(), do:
    Agent.update Exostatic.BuildData, fn _ -> %{} end

  def put_data(key, value), do:
    Agent.update Exostatic.BuildData, &(Map.put &1, key, value)

  def get_data(key), do:
    Agent.get Exostatic.BuildData, &(Map.get &1, key)
end
