defmodule Exostatic.Init do
  @moduledoc """
  This module contains functions which are required to initialize a new Exostatic
  project. These functions should be called by `Exostatic.init/1`.
  """

  import Exostatic.Payload

  def init(dir) do
    dir = if String.ends_with?(dir, "/"), do: dir, else: dir <> "/"

    dir |> check_dir
        |> init(:dir)
        |> init(:infofile)
        |> init(:page)
        |> init(:templates)
        |> init(:gitignore)
        |> finish
  end

  defp check_dir(dir) do
    if File.exists? dir do
      IO.puts "\x1b[93mWarning: The directory `#{dir}` " <>
              "already exists and might not be empty.\x1b[0m"
    end
    dir
  end

  defp finish(dir) do
    IO.puts "\n\x1b[1mSuccessfully initialized a new Exostatic project!"
    IO.puts "try `exostatic build #{dir}` to build the site.\x1b[0m\n"
  end

  # Added themes directory with default_exostatic theme directory
  # TODO: do i do the theme as just copy it over and just create the themes directory? might make more sense
  defp init(dir, :dir) do
    ["posts", "pages", "media", "templates", "themes", "themes/default_exostatic/", "themes/default_exostatic/assets/css",
    "themes/default_exostatic/assets/js", "themes/default_exostatic/assets/images"]
    |> Enum.each(fn x ->
      File.mkdir_p!("#{dir}#{x}")
      IO.puts "Created directory `#{dir}#{x}`."
    end)
    dir
  end

  defp init(dir, :infofile) do
    projinfo =
      %{site_name: "New Website",
        site_description: "Welcome to my website!",
        author: "Somebody",
        author_email: "somebody@example.com",
        base_url: "/",
        date_format: "{WDfull}, {D} {Mshort} {YYYY}",
        preview_length: 200,
        theme: "default_exostatic",
        trailing_slash_links: false
      }
      |> Poison.encode!(pretty: true, indent: 2)
    File.open!("#{dir}exostatic.json", [:write, :utf8], fn f ->
      IO.write(f, projinfo)
    end)
    IO.puts "Generated `#{dir}exostatic.json`."
    dir
  end

  defp init(dir, :page) do
    File.open!("#{dir}pages/index.md", [:write, :utf8], fn f ->
      IO.write(f, "*Hello, world!*\n")
    end)
    File.open!("#{dir}pages/pages.json", [:write, :utf8], fn f ->
      tmp = Poison.encode!([
        %Exostatic.PageInfo{
          name: "index",
          type: "md",
          title: "Welcome!",
          menu: true,
          menu_text: "Home",
          menu_icon: ""}
      ], pretty: true, indent: 2)
      IO.write(f, tmp)
    end)
    IO.puts "Generated `#{dir}pages/pages.json`."
    dir
  end

  defp init(dir, :templates) do

    # grab theme name from exostatic.json
    %{theme: current_theme} = "#{dir}exostatic.json"
                        |> File.read!
                        |> Poison.decode!(keys: :atoms)

    %{base: template_base,
      nav:  template_nav,
      list: template_list,
      page: template_page,
      post: template_post}
    |> Enum.each(fn {k, v} ->
      File.open! "#{dir}themes/#{current_theme}/#{k}.html.eex", [:write, :utf8], fn f ->
        IO.write(f, v)
      end
    end)
    IO.puts "Generated essential templates for bare bones theme into `#{dir}themes/#{current_theme}/`."
    dir
  end

  defp init(dir, :gitignore) do
    File.open!("#{dir}.gitignore", [:write, :utf8], fn f ->
      IO.write(f, "site\n")
    end)
    IO.puts "Generated `#{dir}.gitignore`."
    dir
  end
end
