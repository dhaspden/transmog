defmodule Transmog do
  @moduledoc false

  alias Transmog.Matcher
  alias Transmog.Parser
  alias Transmog.Permutation

  def format(value, pairs) when is_list(value) and is_list(pairs),
    do: Enum.map(value, &format(&1, pairs))

  def format(%{} = value, pairs) when is_list(pairs) do
    with {:ok, pairs} <- Parser.parse(pairs), do: pformat(value, pairs)
  end

  defp pformat(value, pairs) when is_list(value) and is_list(pairs),
    do: Enum.map(value, &pformat(&1, pairs))

  defp pformat(%{} = value, pairs) when is_list(pairs) do
    Enum.map(value, fn
      {key, value} when is_list(value) or is_map(value) ->
        subset = Permutation.subset(pairs, key)
        {Matcher.find(pairs, key), pformat(value, subset)}

      {key, value} ->
        {Matcher.find(pairs, key), value}
    end)
    |> Map.new()
  end
end
