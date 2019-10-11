defmodule Transmog do
  @moduledoc false

  alias Transmog.Matcher
  alias Transmog.Parser
  alias Transmog.Permutation

  def format(value, pairs) when is_list(value) and is_list(pairs),
    do: Enum.map(value, &format(&1, pairs))

  def format(%{} = value, pairs) when is_list(pairs) do
    if Parser.valid?(pairs) do
      pformat(value, pairs)
    else
      with {:ok, pairs} <- Parser.parse(pairs), do: pformat(value, pairs)
    end
  end

  defp pformat(%{} = value, pairs) when is_list(pairs) do
    value
    |> Enum.map(fn
      {key, value} when is_list(value) or is_map(value) ->
        subset = Permutation.subset(pairs, key)
        {Matcher.find(pairs, key), format(value, subset)}

      {key, value} ->
        {Matcher.find(pairs, key), value}
    end)
    |> Map.new()
  end
end
