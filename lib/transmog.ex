defmodule Transmog do
  @moduledoc """
  `Transmog` is a module which makes it easy to perform a deep rename of keys in
  a map or list of maps using a key mapping. The key mapping is a list of two
  tuples which are dot notation strings representing the path to update and the
  resulting name of the key after formatting using `format/2`.

  The format for a key mapping disregards whether or not a list is present while
  traversing the tree. If a list is discovered during the traversal then the
  requested changes will be duplicated to all nested resources.

  ## Examples

      iex> key_mapping = [{":a", "b"}, {":a.:b", "b.a"}]

  This `key_mapping` above represents a format which changes `:a` to `"b"` in
  the first level of the map. In the second level of the map (including lists of
  maps) `:b` will be updated to `"a"`.

  When running a format using that `key_mapping` we will expect to see the
  following result.

  ## Examples

      iex> source = [%{a: %{b: "c"}}, %{a: %{b: "d"}}]
      iex> {:ok, formatted_source} = Transmog.format(source, key_mapping)
      iex> formatted_source
      [%{"b" => %{"a" => "c"}}, %{"b" => %{"a" => "d"}}]

  In order to apply the transformation to special values such as numbers, floats
  and strings with periods in them then you can supply the path directly and
  bypass the parser.

  ## Examples

      iex> key_mapping = [{[1], "1"}]
      iex> source = [%{1 => "a"}]
      iex> {:ok, formatted_source} = Transmog.format(source, key_mapping)
      iex> formatted_source
      [%{"1" => "a"}]

      iex> key_mapping = [{["a.b"], "a_b"}]
      iex> source = [%{"a.b" => "a"}]
      iex> {:ok, formatted_source} = Transmog.format(source, key_mapping)
      iex> formatted_source
      [%{"a_b" => "a"}]

  """

  alias Transmog.Matcher
  alias Transmog.Permutation
  alias Transmog.TempParser, as: Parser

  @typedoc """
  `formattable` is the type of values that can be formatted by `format/2`.
  """
  @type formattable :: list | map

  @typedoc """
  `key` is the type of valid key parsed in a key mapping.
  """
  @type key :: atom | binary | float | non_neg_integer

  @typedoc """
  `pair` is the type for a valid pair. A valid pair is a two tuple consisting of
  two equal length list of keys. See `key` above.
  """
  @type pair :: {[key], [key]}

  @typedoc """
  `raw_pair` is the type for a valid input pair. An input pair following the
  string format using dot notation. Alternatively you could choose to supply the
  pairs manually. This could be useful if you want to use values that cannot be
  easily parsed by the parser.

  Some examples would be if you want to use integers, floats or map keys with
  period characters in them.
  """
  @type raw_pair :: {binary | [key], binary | [key]}

  @typedoc """
  `result` is the type for the output from `format/2`.
  """
  @type result :: {:ok, formattable} | Parser.error()

  @doc """
  `format/2` takes either a list or a map and changes the keys of the maps
  contained within using a key mapping as a guide. Before any formatting is
  done the mapping is first validated by `Transmog.Parser`. If the mapping is
  not valid then `{:error, :invalid_pair}` will be returned.

  ## Examples

      iex> key_mapping = [{":a", "b"}, {":a.b", "b.:a"}]
      iex> fields = %{a: %{"b" => "c"}}
      iex> {:ok, formatted_fields} = Transmog.format(fields, key_mapping)
      iex> formatted_fields
      %{"b" => %{a: "c"}}

  """
  @spec format(value :: formattable, pairs :: [pair] | [raw_pair]) :: result
  def format(value, pairs) when is_list(value) and is_list(pairs) do
    with {:ok, pairs} <- Parser.parse(pairs) do
      {:ok, Enum.map(value, &format_level(&1, pairs))}
    end
  end

  def format(%{} = value, pairs) when is_list(pairs) do
    with {:ok, pairs} <- Parser.parse(pairs), do: {:ok, format_level(value, pairs)}
  end

  # Formats a single level of a map. In the event that there is another level of
  # either a map or a list then a subset pair list will be computed and the
  # function will recursively format the children.
  @spec format_level(value :: map, pairs :: list(pair) | list(raw_pair)) :: map
  defp format_level(%{} = value, pairs) when is_list(pairs) do
    value
    |> Enum.map(fn
      {key, value} when is_list(value) ->
        subset = Permutation.subset(pairs, key)
        {Matcher.find(pairs, key), Enum.map(value, &format_level(&1, subset))}

      {key, value} when is_map(value) ->
        subset = Permutation.subset(pairs, key)
        {Matcher.find(pairs, key), format_level(value, subset)}

      {key, value} ->
        {Matcher.find(pairs, key), value}
    end)
    |> Map.new()
  end
end
