# script to show how receive blocks until a message is received

power_nap = fn ->
  time = :rand.uniform(10_000)
  :timer.sleep(time)
  time
end

parent = self()

spawn(fn -> send(parent, {:sleep, power_nap.()}) end)

receive do
  {:sleep, time} -> IO.puts "Slept #{time} ms"
end
