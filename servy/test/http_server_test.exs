defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer
  alias Servy.Client

  test "accecpt a request on a socket and sends back a response using HTTPoison" do

    spawn(HttpServer, :start, [4000])

    {:ok, response} = HTTPoison.get("http://localhost:4000/wildthings")

    assert response.status_code == 200
    assert response.body == "Bears, Lions, Tigers"
  end

  test "accecpt a request on a socket and sends back a response using my client" do

    spawn(HttpServer, :start, [4000])

    request = """
    GET /wildthings HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = Client.send_request(request)

    assert_response = """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 20\r
    \r
    Bears, Lions, Tigers
    """

    assert response == assert_response
  end

  test "accecpt 5 requests on a socket and sends back a response using HTTPoison" do

    spawn(HttpServer, :start, [4000])

    parent = self()

    max_concurrent_requests = 5

    1..max_concurrent_requests |> Enum.each(fn _ -> spawn(fn -> send(parent, {:ok, HTTPoison.get("http://localhost:4000/wildthings")} ) end) end)

    1..max_concurrent_requests |> Enum.each(fn _ -> receive do {:ok, response} -> assert response.status_code == 200 end end)
  end
end
