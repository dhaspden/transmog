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
end
