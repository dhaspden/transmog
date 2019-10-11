defmodule Transmog.Matcher do
  @moduledoc false

  @spec find(pairs :: [Transmog.pair()], key :: Transmog.key()) :: Transmog.key()
  def find(pairs, key) when is_list(pairs) and (is_atom(key) or is_binary(key)) do
    case Enum.find(pairs, &pair_matches?(key, &1)) do
      nil -> key
      {[_], [to]} -> to
    end
  end

  @spec pair_matches?(key :: Transmog.key(), pair :: Transmog.pair()) :: boolean
  defp pair_matches?(key, {[from], [_]}), do: from == key
  defp pair_matches?(_, _), do: false
end
