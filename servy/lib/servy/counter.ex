defmodule Servy.Counter do

  @name :counter

  def start() do
    pid = spawn(__MODULE__, :listen_loop, [%{}])
    Process.register(pid, @name)
    pid
  end

  def bump_count(url) do
    send @name, {self(), :bump_count, url}

    receive do {:response, status} -> status end
  end

  def get_count(url) do
    send @name, {self(), :get_count, url}
    receive do {:response, status} -> status end
  end

  def get_counts() do
    send @name, {self(), :get_counts}
    receive do {:response, status} -> status end
  end

  def listen_loop(state) do
    receive do
      {sender, :bump_count, url} ->
        new_state = Map.update(state, url, 1, &(&1 + 1))
        send sender, {:response, Map.get(new_state, url)}
        listen_loop(new_state)
      {sender, :get_count, url} ->
        count = Map.get(state, url, 0)
        send sender, {:response, count}
        listen_loop(state)
      {sender, :get_counts} ->
        send sender, {:response, state}
        listen_loop(state)
      unexpected ->
        IO.puts "Unexpected message: #{inspect unexpected}"
        listen_loop(state)
    end
  end
end
