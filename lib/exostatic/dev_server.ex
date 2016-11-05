defmodule Exostatic.DevServer do
  alias Exostatic.DevServer.Service

  def run(dir, port) do
    import Supervisor.Spec

    dir = String.ends_with?(dir, "/") && dir || dir <> "/"
    uniq = Base.url_encode64 <<System.monotonic_time::size(64)>>, padding: false
    site = "/tmp/exostatic_" <> uniq


    if not File.exists? "#{dir}exostatic.json" do
      IO.puts "\x1b[31mError: `#{dir}exostatic.json` not found."
      IO.puts "Make sure you point at a valid Exostatic project directory.\x1b[0m"
    else
      %{base_url: base} = "#{dir}exostatic.json"
                          |> File.read!
                          |> Poison.decode!(keys: :atoms)

      children = [
        worker(__MODULE__, [site, base, port], function: :start_server),
        worker(Exostatic.DevServer.Service, [dir, site, port])
      ]

      opts = [strategy: :one_for_one, name: Exostatic.DevServer.Supervisor]
      Supervisor.start_link children, opts

      ensure_service_started
      Service.rebuild

      looper {port, site}
    end
  end

  def start_server(dir, base, port) do
    routes = [
      {"/[...]", Exostatic.DevServer.Handler, [dir: dir, base: base]}
    ]
    dispatch = :cowboy_router.compile [{:_, routes}]
    opts = [port: port]
    env = [dispatch: dispatch]
    {:ok, pid} = :cowboy.start_http Exostatic.DevServer.Http, 100, opts, env: env
    {:ok, pid}
  end

  defp ensure_service_started() do
    case GenServer.whereis Service do
      nil -> ensure_service_started
      _   -> :ok
    end
  end

  defp looper(state) do
    {port, site} = state
    cmd = "#{port}> " |> IO.gets |> String.trim
    case cmd do
      "help"  -> cmd :help, state
      "build" -> cmd :build, state
      "quit"  -> cmd :quit, site
      ""      -> looper state
      _       ->
        IO.puts "Type `help` for the list of available commands."
        looper state
    end
  end

  defp cmd(:help, state) do
    IO.puts "Available commands are:"
    IO.puts "  help   Displays this help message"
    IO.puts "  build  Rebuilds the project"
    IO.puts "  quit   Stops the server and quit"
    looper state
  end

  defp cmd(:quit, site) do
    IO.puts "Stopping server..."
    :ok = :cowboy.stop_listener Exostatic.DevServer.Http
    :ok = Supervisor.stop Exostatic.DevServer.Supervisor
    IO.puts "Removing temporary directory `#{site}`..."
    File.rm_rf! site
    :quit
  end

  defp cmd(:build, state) do
    Service.rebuild
    looper state
  end
end
