defimpl Transmog.Parser, for: BitString do
  @moduledoc """
  Implementation of `Transmog.Parser` for strings. Parses strings which are
  represented as dot notation and maps them to values in a nested map, struct or
  list.

  ## Examples

      "a.:b.c" #=> References a map or list with key path ["a", :b, "c"]
      ":a.1"   #=> References a map or list with key path [:a, "1"]

  As you can see there are some caveats to this dot notation:

  * You are not able to represent paths that contain anything other than atoms
    or strings.

  ## Examples

      iex> string = "credentials.:first_name"
      iex> {:ok, key_path} = Transmog.Parser.parse(string)
      iex> key_path
      ["credentials", :first_name]

      iex> string = "credentials.:first_name"
      iex> Transmog.Parser.parse!(string)
      ["credentials", :first_name]

      #=> Notice: we can escape a period in order for it to be preserved
      iex> string = "credentials\\\\.first_name"
      iex> Transmog.Parser.parse!(string)
      ["credentials.first_name"]

      #=> Notice: an empty string, like the empty list, is considered invalid
      iex> string = ""
      iex> Transmog.Parser.parse(string)
      {:error, :invalid_key_path}

      iex> string = ""
      iex> Transmog.Parser.parse!(string)
      ** (Transmog.InvalidKeyPathError) key path is not valid (\"\")

  """

  alias Transmog.InvalidKeyPathError
  alias Transmog.Parser

  # The token that each part of the path is split on
  @token "."

  @doc """
  `parse/1` parses a string into a key path. If the string is empty then it is
  considered invalid and returned immediately. Non-empty strings will be parsed
  by splitting on the dot character to generate the path.

  Atoms that are found during the parse, ie. strings that are prefixed with a
  colon, will be safely converted to an atom.

  ## Examples

      iex> string = "a.:b.c"
      iex> {:ok, key_path} = Transmog.Parser.parse(string)
      iex> key_path
      ["a", :b, "c"]

      iex> string = "a\\\\.b.c"
      iex> {:ok, key_path} = Transmog.Parser.parse(string)
      iex> key_path
      ["a.b", "c"]

      iex> string = "a\\\\:b.c"
      iex> {:ok, key_path} = Transmog.Parser.parse!(string)
      iex> key_path
      ["a.:b", "c"]

  """
  @spec parse(string :: binary) :: {:ok, list(term)} | Parser.error()
  def parse(""), do: {:error, :invalid_key_path}

  def parse(string) when is_binary(string) do
    parts =
      string
      |> split_on_token()
      |> Enum.map(&parse_field/1)

    {:ok, parts}
  end

  @doc """
  `parse!/1` parses a string into a key path. If the string is empty then it is
  considered invalid and an error is raised. Otherwise the parse will delegate
  to `parse/1`.

  ## Examples

      iex> string = "a.:b.c"
      iex> Transmog.Parser.parse!(string)
      ["a", :b, "c"]

      iex> string = "a\\\\.b.c"
      iex> Transmog.Parser.parse!(string)
      ["a.b", "c"]

      iex> string = "a\\\\:b.c"
      iex> Transmog.Parser.parse!(string)
      ["a.:b", "c"]

      iex> string = ""
      iex> Transmog.Parser.parse!(string)
      ** (Transmog.InvalidKeyPathError) key path is not valid (\"\")

  """
  @spec parse!(string :: binary) :: list(term)
  def parse!(""), do: InvalidKeyPathError.new("")
  def parse!(string) when is_binary(string), do: elem(parse(string), 1)

  # Parses a single field of the dot notation string. If the field begins with
  # a colon, then it is parsed as an atom. Only existing atoms will be used to
  # be safe.
  @spec parse_field(field :: binary) :: atom | binary
  defp parse_field(":" <> field) when is_binary(field), do: String.to_existing_atom(field)
  defp parse_field(field) when is_binary(field), do: field

  # Helper function which stores the logic for splitting a string on the token
  # character. At this time the token character is a period.
  @spec split_on_token(string :: binary) :: list(binary)
  defp split_on_token(string) when is_binary(string) do
    string
    |> String.split(~r[(?<!\\)#{Regex.escape(@token)}])
    |> Enum.map(&String.replace(&1, "\\", ""))
  end
end
