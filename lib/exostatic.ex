defmodule Exostatic do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Agent, [fn -> %{} end, [name: Exostatic.BuildData]], id: "exostatic_bd"),
      worker(Agent, [fn -> [] end, [name: Exostatic.PostInfoStorage]], id: "exostatic_pis")
    ]

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
