defmodule Servy.Client do

  def send_request(request) do
    somehostinnet = 'localhost' # to make it runnable on one machine

    {:ok, sock} = :gen_tcp.connect(somehostinnet, 4000, [:binary, packet: :raw, active: false])

    :ok = :gen_tcp.send(sock, request)

    :ok = :gen_tcp.close(sock)

  end

end

  request = """
GET /bears HTTP/1.1\r
Host: example.com\r
User-Agent: ExampleBrowser/1.0\r
Accept: */*\r
\r
"""

spawn(fn -> Servy.HttpServer.start(4000) end)

response = Servy.Client.send_request(request)
IO.puts(response)
