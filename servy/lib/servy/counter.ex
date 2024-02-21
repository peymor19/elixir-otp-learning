defmodule Servy.GenericServer do

  def start(callback_module, initial_state, name) do
    pid = spawn(__MODULE__, :listen_loop, [initial_state, callback_module])
    Process.register(pid, name)
    pid
  end

  def call(pid, message) do
    send pid, {:call, self(), message}

    receive do {:response, response} -> response end
  end

  def cast(pid, message) do
    send pid, {:cast, message}
  end

  def listen_loop(state, callback_module) do
    receive do
      {:call, sender, message} when is_pid(sender) ->
        {response, new_state} = callback_module.handle_call(message, state)
        send sender, {:response, response}
        listen_loop(new_state, callback_module)
      {:cast, message} ->
        new_state = callback_module.handle_cast(message, state)
        listen_loop(new_state, callback_module)
      unexpected ->
        IO.puts "Unexpected message: #{inspect unexpected}"
        listen_loop(state, callback_module)
    end
  end
end

defmodule Servy.Counter do

  @name :counter

  alias Servy.GenericServer

  def start() do
    Servy.GenericServer.start(__MODULE__, %{}, @name)
  end

  def bump_count(url) do
    GenericServer.call @name, {:bump_count, url}
  end

  def get_count(url) do
    GenericServer.call @name, {:get_count, url}
  end

  def get_counts() do
    GenericServer.call @name, :get_counts
  end

  def reset() do
    GenericServer.cast @name, :reset
  end

  def handle_call({:bump_count, url}, state) do
      new_state = Map.update(state, url, 1, &(&1 + 1))
      {:ok, new_state}
  end

  def handle_call({:get_count, url}, state) do
      count = Map.get(state, url, 0)
      {count, state}
  end

  def handle_call(:get_counts, state) do
      {state, state}
  end

  def handle_cast(:reset, _state) do
      %{}
  end
end


alias Servy.Counter

Counter.start()

IO.inspect Counter.bump_count("/hello")
IO.inspect Counter.bump_count("/hello")
IO.inspect Counter.bump_count("/hello")
IO.inspect Counter.bump_count("/hello")

IO.inspect Counter.get_counts()

IO.inspect Counter.reset()

IO.inspect Counter.get_counts()

IO.inspect Counter.bump_count("/hello")
IO.inspect Counter.bump_count("/hello")
IO.inspect Counter.bump_count("/hello")
IO.inspect Counter.bump_count("/hello")

IO.inspect Counter.get_counts()



