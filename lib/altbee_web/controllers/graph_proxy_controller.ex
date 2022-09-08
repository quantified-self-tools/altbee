defmodule AltbeeWeb.GraphProxyController do
  use AltbeeWeb, :controller

  alias Altbee.Assets

  def index(conn, %{"url" => "https://cdn.beeminder.com/" <> _path = url}) do
    proxy_graph(conn, url)
  end

  def index(conn, %{"url" => "https://bmndr.s3.amazonaws.com/" <> _path = url}) do
    proxy_graph(conn, url)
  end

  def index(conn, %{"url" => "https://s3.amazonaws.com/bmndr/" <> _path = url}) do
    proxy_graph(conn, url)
  end

  def index(conn, _params) do
    conn
    |> put_status(400)
    |> json(%{
      error: "Invalid graph URL"
    })
  end

  defp proxy_graph(conn, url) do
    {:ok, %{body: graph, headers: headers}} =
      Finch.build(:get, url)
      |> Finch.request(AltbeeFinch)

    content_type = Assets.get_header(headers, "content-type", "application/octet-stream")

    graph = fixup_graph(graph, content_type)

    conn
    |> put_resp_header("content-type", content_type)
    |> send_resp(200, graph)
  end

  defp fixup_graph(graph, "image/svg" <> _) do
    # Includes image/svg and image/svg+xml
    Regex.replace(
      ~r{"(https://(?:bmndr\.s3\.amazonaws\.com|s3\.amazonaws\.com/bmndr)/[^"]*)"},
      graph,
      fn _, subresource_url ->
        inline_data_url = Assets.get_inline_data_url(subresource_url)
        "\"#{inline_data_url}\""
      end
    )
  end

  defp fixup_graph(graph, _) do
    graph
  end
end
