defmodule Transmog.Parser do
  @moduledoc """
  `Parser` is a module which parses the two tuple dot notation strings into a
  format that can be understood by the rest of the library. It is able to parse
  values of the format "a.b.c" into the library format of ["a", "b", "c"],
  for example.

  It exposes two functions. `parse/1` is the main exported function from this
  module which parses the dot notation strings into the special format.
  `valid?/1` takes a parsed value and returns whether or not the pairs value
  is valid.
  """

  @typedoc """
  `error` is the type for an error that occurs during parsing. During parsing if
  an invalid pair is found then the value described in this type is returned.
  """
  @type error :: {:error, :invalid_pair}

  @doc """
  `parse/1` converts a list of raw pairs into a list of pairs that can be
  understood by the formatter. It performs the parse according to the following
  rules:

  1. Each pair must be a two tuple of strings.
  2. Each string can use dot notation to represent nested values.
  3. Atoms are represented literally, ie. ":name" for `:name`.

  ## Examples

      iex> pairs = [{"a.b.c", "c.b.a"}]
      iex> Transmog.Parser.parse(pairs)
      [{["a", "b", "c"], ["c", "b", "a"]}]

      iex> pairs = [{":a.b", ":a.:b"}]
      iex> Transmog.Parser.parse(pairs)
      [{[:a, "b"], [:a, :b]}]

  """
  @spec parse(pairs :: [Transmog.raw_pair()]) :: {:ok, [Transmog.pair()]} | error
  def parse(pairs) when is_list(pairs) do
    case Enum.reduce_while(pairs, [], &parse_pair/2) do
      {:error, _} = error -> error
      pairs -> {:ok, pairs}
    end
  end

  @doc """
  `valid?/1` checks that a list of pairs is valid. A list of pairs is considered
  valid if each pair consists of equal length lists of keys. A key is either an
  atom or a string.

  ## Examples

      iex> pairs = [{["a", "b"], [:a, :b]}]
      iex> Transmog.Parser.valid?(pairs)
      true

      iex> pairs = [{["a"], []}]
      iex> Transmog.Parser.valid?(pairs)
      false

      iex> pairs = [{[], [:a]}]
      iex> Transmog.Parser.valid?(pairs)
      false

  """
  @spec valid?(pairs :: term) :: boolean
  def valid?(pairs) when is_list(pairs), do: Enum.all?(pairs, &valid_pair?/1)
  def valid?(_), do: false

  # Converts a dot notation string into a path list. Atoms will be parsed from
  # strings if applicable at this stage.
  @spec from_string(path :: binary) :: [Transmog.key()]
  defp from_string(path) when is_binary(path) do
    path
    |> String.split(".")
    |> Enum.map(&parse_field/1)
  end

  # Parses a single field of the dot notation string. If the field begins with
  # a colon, then it is parsed as an atom. Only existing atoms will be used to
  # be safe.
  @spec parse_field(field :: binary) :: Transmog.key()
  defp parse_field(":" <> field) when is_binary(field), do: String.to_existing_atom(field)
  defp parse_field(field) when is_binary(field), do: field

  # Parses a pair for `parse/1`. Returns values that are used by
  # `Enum.reduce_while/3` to stop execution early if an invalid value is
  # encountered.
  @spec parse_pair(pair :: Transmog.pair(), pairs :: [Transmog.pair()]) ::
          {:cont, [Transmog.pair()]} | {:halt, error}
  defp parse_pair({from, to}, pairs) when is_binary(from) and is_binary(to) do
    {:cont, pairs ++ [{from_string(from), from_string(to)}]}
  end

  defp parse_pair(_, _), do: {:halt, {:error, :invalid_pair}}

  # Determines if a single field in a path is valid. A single field is valid if
  # it is either an atom or a string.
  @spec valid_field?(field :: Transmog.key()) :: boolean
  defp valid_field?(field) when is_atom(field) or is_binary(field), do: true
  defp valid_field?(_), do: false

  # Determines if a pair is valid. A pair is valid if both lists of keys in the
  # pair are of the same length and if each key in the list is valid.
  @spec valid_pair?(pair :: Transmog.pair()) :: boolean
  defp valid_pair?({from, to}) when is_list(from) and is_list(to) do
    length(from) == length(to) && Enum.all?(from ++ to, &valid_field?/1)
  end

  defp valid_pair?(_), do: false
end
