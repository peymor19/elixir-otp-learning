defmodule Servy.Client do

  def send_request(request) do
    somehostinnet = 'localhost' # to make it runnable on one machine

    {:ok, socket} = :gen_tcp.connect(somehostinnet, 4000, [:binary, packet: :raw, active: false])

    :ok = :gen_tcp.send(socket, request)

    {:ok, response} = :gen_tcp.recv(socket, 0)

    :ok = :gen_tcp.close(socket)

    response

  end

end
