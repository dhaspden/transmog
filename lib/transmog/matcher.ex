defmodule Transmog.Matcher do
  @moduledoc """
  `Matcher` is a module which is responsible for performing a mapping from one
  key to another given a valid list of pairs.
  """

  @doc """
  `find/2` takes a list of pairs and a key and finds the pair in the list which
  matches. If a match is found then the opposite key in the key mapping will be
  returned as the key that the value should map to.

  ## Examples

      iex> pairs = [{[:a], ["a"]}]
      iex> Transmog.Matcher.find(pairs, :a)
      "a"

      iex> pairs = [{[:a], ["a"]}]
      iex> Transmog.Matcher.find(pairs, :b)
      :b

  """
  @spec find(pairs :: [Transmog.pair()], key :: Transmog.key()) :: Transmog.key()
  def find(pairs, key)
      when is_list(pairs) and (is_atom(key) or is_binary(key) or is_number(key)) do
    case Enum.find(pairs, &pair_matches?(key, &1)) do
      nil -> key
      {[_], [to]} -> to
    end
  end

  # Given a pair and a key, determines if the pair has only a single element. If
  # there is only a single element then it checks if the first element in the
  # pair matches the key.
  @spec pair_matches?(key :: Transmog.key(), pair :: Transmog.pair()) :: boolean
  defp pair_matches?(key, {[from], [_]}), do: from == key
  defp pair_matches?(_, _), do: false
end
