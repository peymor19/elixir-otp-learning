defmodule Servy.Plugins do

  require Logger

  alias Servy.Conv

  @doc "Logs 404 requests."
  def track(%Conv{status: 404, path: path} = conv) do
    if Mix.env != :test do
      IO.puts "warning: #{path} is on the loose!"
    end
    conv
  end

  def track(%Conv{} = conv), do: conv

  # pattern matching with maps
  def rewrite_path(%{path: "/wildlife"} = conv) do
    %{ conv | path: "/wildthings" }
  end

  def rewrite_path(%{path: "/bears?id=" <> id} = conv) do
    %{ conv | path: "/bears/#{id}" }
  end

  def rewrite_path(%Conv{} = conv), do: conv

  def log(%Conv{} = conv)do
    if Mix.env == :dev do
      IO.inspect conv
    end
    conv
  end
end
