defmodule Altbee.Tags do
  require Logger
  use Retry.Annotation

  alias Altbee.Accounts.User
  alias Altbee.BeeminderError

  @beeminder_root_url Application.compile_env(:altbee, :root_url)
  @beeminder_user_data_url Application.compile_env(:altbee, :user_data_url)

  def refresh_tags_async(%User{username: username} = user) do
    pid = self()

    Task.start_link(fn ->
      case get_tags(user) do
        {:ok, tags} ->
          Cachex.put(:tags_cache, username, tags)

          send(pid, {:tags, tags})

        {:error, err} ->
          msg = Exception.message(err)

          Logger.error("Failed to fetch tags for #{username}: #{msg}")
      end
    end)
  end

  @retry with: exponential_backoff() |> randomize() |> expiry(10_000)
  def get_tags(%User{access_token: access_token, username: username}) do
    authenticate_url =
      "#{@beeminder_user_data_url}?access_token=#{access_token}&redirect_to_url=/"

    home_url = "#{@beeminder_root_url}/#{username}"

    with {:ok, %{status: 302, headers: headers}} <-
           Finch.build(:get, authenticate_url)
           |> Finch.request(AltbeeFinch),
         cookie <- extract_cookie_from_headers(headers),
         {:ok, %{status: 200, body: response_html}} <-
           Finch.build(:get, home_url, [
             {"Cookie", cookie},
             {"Accept", "text/html"}
           ])
           |> Finch.request(AltbeeFinch),
         {:ok, tags} <- extract_tags_from_html(response_html) do
      {:ok, tags}
    else
      {:ok, %Finch.Response{} = response} -> {:error, %BeeminderError{response: response}}
      {:error, _} = err -> err
    end
  end

  def load_tags_from_cache(%User{username: username}) do
    case Cachex.get(:tags_cache, username) do
      {:ok, nil} -> %{}
      {:ok, tags} -> tags
      {:error, _} -> %{}
    end
  end

  defp extract_tags_from_html(html) do
    with {:ok, doc} <- Floki.parse_document(html) do
      tags =
        for {_, attrs, _} <- Floki.find(doc, "[data-slug][data-tags]") do
          %{slug: slug, tags: tags} =
            Enum.reduce(attrs, %{slug: nil, tags: []}, fn
              {"data-slug", slug}, acc -> %{acc | slug: slug}
              {"data-tags", tags}, acc -> %{acc | tags: split_tags(tags)}
              _, acc -> acc
            end)

          {slug, tags}
        end

      {:ok, Map.new(tags)}
    end
  end

  defp extract_cookie_from_headers(headers) do
    for({"set-cookie", set_cookie} <- headers, do: set_cookie)
    |> List.first()
    |> String.split(";")
    |> List.first()
  end

  defp split_tags(""), do: []
  defp split_tags(tags), do: String.split(tags, ",")
end
