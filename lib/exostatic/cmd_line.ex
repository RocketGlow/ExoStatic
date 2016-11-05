defmodule Exostatic.CmdLine do
  @moduledoc """
  This module contains the entry point for the command line program
  (`Exostatic.Cmdline.main/1`).
  """

  @opt_build    [parallel: :boolean, output: :string]
  @opt_server   [port: :integer]
  @alias_build  [p: :parallel, o: :output]
  @alias_server [p: :port]

  def main(["init"|args]) do
    info
    case args do
      [] -> Exostatic.Init.init(".")
      [dir|_] -> Exostatic.Init.init(dir)
    end
  end

  def main(["build"|args]) do
    info
    {opts, args, errors} =
      OptionParser.parse(args, strict: @opt_build, aliases: @alias_build)
    mode = Keyword.get(opts, :parallel) && :parallel || :sequential
    out = Keyword.get(opts, :output)
    case {args, errors} do
      {[], []}      -> Exostatic.Build.build(".", out, mode, true)
      {[dir|_], []} -> Exostatic.Build.build(dir, out, mode, true)
      {_, _error}   -> usage
    end
  end

  def main(["server"|args]) do
    info
    {opts, args, errors} =
      OptionParser.parse(args, strict: @opt_server, aliases: @alias_server)
    port = Keyword.get(opts, :port) || 3000
    case {args, errors} do
      {[], []}      -> Exostatic.DevServer.run(".", port)
      {[dir|_], []} -> Exostatic.DevServer.run(dir, port)
      {_, _error}   -> usage
    end
  end

  def main(["help"|_]) do
    info
    usage
  end

  def main(["version"|_]) do
    info
  end

  def main(_args) do
    info
    usage
  end

  defp info() do
    IO.puts "\x1b[1mExostatic -- Static website and blog generator using Elixir"
    IO.puts "Version 0.1.0. Copyright (C) 2016 Chris Allen Moore. <chris@rocketglow.com>\x1b[0m"
    IO.puts "inspired by the wonderful static website builder, Serum"
  end

  defp usage() do
    IO.puts """
    Usage: exostatic <task>

      Available Tasks:
      \x1b[96minit\x1b[0m [dir]               Initializes a new Exostatic project

      \x1b[96mbuild\x1b[0m [options] [dir]    Builds an existing Exostatic project
        dir                    (optional) Path to a Exostatic project
        -p, --parallel         Builds the pages parallelly
        -o, --output <outdir>  Specifies the output directory

      \x1b[96mserver\x1b[0m [options] [dir]   Starts a web server
        dir                    (optional) Path to a Exostatic project
        -p, --port             Specifies HTTP port the server listens on
                               (Default is 3000)

      \x1b[96mhelp\x1b[0m                     Shows this help message

      \x1b[96mversion\x1b[0m                  Shows the version information
    """
  end
end
