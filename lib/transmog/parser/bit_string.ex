defimpl Transmog.Parser, for: BitString do
  @moduledoc """
  Implementation of `Transmog.Parser` for strings. Parses strings which are
  represented as a dot notation and maps them to values in a nested map or list.

  ## Examples

      "a.:b.c" #=> References a map or list with key path ["a", :b, "c"]
      ":a.1" #=> References a map or list with key path [:a, "1"]

  As you can see there are some caveats to this dot notation:

  * You are not able to represent paths that contain anything other than atoms
    or strings.
  * You are not able to represent strings that contain a dot, for example the
    key path `["a.b", :c]`.

  ## Examples

      iex> string = "credentials.:first_name"
      iex> {:ok, key_path} = Transmog.Parser.parse(string)
      iex> key_path
      ["credentials", :first_name]

      iex> string = ""
      iex> Transmog.Parser.parse(string)
      {:error, :invalid_key_path}

  """

  alias Transmog.KeyPair

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

  """
  @spec parse(string :: binary) :: {:ok, list(term)} | {:error, :invalid_key_path}
  def parse(""), do: {:error, :invalid_key_path}

  def parse(string) when is_binary(string) do
    parts =
      string
      |> String.split(".")
      |> Enum.map(&parse_field/1)

    {:ok, parts}
  end

  # Parses a single field of the dot notation string. If the field begins with
  # a colon, then it is parsed as an atom. Only existing atoms will be used to
  # be safe.
  @spec parse_field(field :: binary) :: atom | binary
  defp parse_field(":" <> field) when is_binary(field), do: String.to_existing_atom(field)
  defp parse_field(field) when is_binary(field), do: field
end
