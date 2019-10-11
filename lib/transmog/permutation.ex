defmodule Transmog.Permutation do
  @moduledoc false

  def subset(pairs, key) when is_list(pairs) and (is_atom(key) or is_binary(key)) do
    pairs
    |> Enum.filter(&pair_starts_with_key?(&1, key))
    |> Enum.map(&advance_pair_level/1)
    |> Enum.reject(&pair_empty?/1)
  end

  defp advance_pair_level({from, to}), do: {Enum.drop(from, 1), Enum.drop(to, 1)}

  defp pair_empty?({[], _}), do: true
  defp pair_empty?({_, []}), do: true
  defp pair_empty?(_), do: false

  defp pair_starts_with_key?({[from | _], _}, key), do: from == key
end
