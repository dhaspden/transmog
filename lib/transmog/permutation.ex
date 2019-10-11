defmodule Transmog.Permutation do
  @moduledoc """
  `Permutation` is the module which is responsible for calculating permutations
  of pairs. It exposes a single function, `subset/2` which is used when
  formatting values to assist the formatter in advancing to the next level in
  the tree structure.
  """

  @doc """
  `subset/2` calculates a subset of a list of pairs. It does so by taking a
  `key` and retaining all pairs that begin with that key. Once that subset is
  calculated then the `key` itself is removed from each result. Effectively
  this means that we have a key mapping for one level down in the tree
  structure.

  ## Examples

      iex> pairs = [{[:a], [:b]}, {[:a, :b], ["a", "b"]}]
      iex> Transmog.Permutation.subset(pairs, :a)
      [{[:b], ["b"]}]

  """
  @spec subset(pairs :: [Transmog.pair()], key :: Transmog.key()) :: [Transmog.pair()]
  def subset(pairs, key) when is_list(pairs) and (is_atom(key) or is_binary(key)) do
    pairs
    |> Enum.filter(&pair_starts_with_key?(&1, key))
    |> Enum.map(&advance_pair_level/1)
    |> Enum.reject(&pair_empty?/1)
  end

  # Removes the first element from each pair. These pairs have already been
  # matched so we are just removing the key that we were matching on here.
  @spec advance_pair_level(pair :: Transmog.pair()) :: Transmog.pair()
  defp advance_pair_level({from, to}), do: {Enum.drop(from, 1), Enum.drop(to, 1)}

  # Determines if a key in the pair is empty.
  @spec pair_empty?(pair :: Transmog.pair()) :: boolean
  defp pair_empty?({[], _}), do: true
  defp pair_empty?({_, []}), do: true
  defp pair_empty?(_), do: false

  # Determines if a pair contains a search key.
  @spec pair_starts_with_key?(pair :: Transmog.pair(), key :: Transmog.key()) :: boolean
  defp pair_starts_with_key?({[from | _], _}, key), do: from == key
end
