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

  test "accepts 5 concurrent requests on a socket and sends back a response" do
    spawn(HttpServer, :start, [5000])

    url = "http://localhost:5000/wildthings"
    # Spawn the client processes
    1..5
      |> Enum.map(fn _ -> Task.async(fn -> HTTPoison.get(url) end) end)
      |> Enum.map(&Task.await/1)
      |> Enum.map(&assert_successful_response/1)
  end

  defp assert_successful_response({:ok, response}) do
    assert response.status_code == 200
    assert response.body == "Bears, Lions, Tigers"
  end

end
