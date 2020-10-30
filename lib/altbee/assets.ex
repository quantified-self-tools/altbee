defmodule Altbee.Assets do
  def get_header(headers, header, default \\ nil)
      when is_list(headers) and is_binary(header) do
    Enum.find(headers, fn {key, _value} ->
      # Ignore case when finding the correct header
      :string.equal(header, key, true)
    end)
    |> case do
      {_key, value} -> value
      nil -> default
    end
  end

  def get_inline_data_url(url)
      when is_binary(url) do
    Cachex.fetch(:assets_subresource_cache, url, &fetch_subresource/1)
    |> case do
      # cache hit
      {:ok, data_url} -> data_url
      # cache miss
      {:commit, data_url} -> data_url
    end
  end

  defp fetch_subresource(url)
       when is_binary(url) do
    {:ok, %{body: body, headers: headers, status: 200}} =
      Finch.build(:get, url)
      |> Finch.request(AltbeeFinch)

    base_64_data = Base.encode64(body)
    type = get_header(headers, "content-type", "application/octet-stream")

    {:commit, "data:#{type};base64,#{base_64_data}"}
  end
end
