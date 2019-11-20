defimpl Transmog.Parser, for: List do
  @moduledoc """
  Implementation of `Transmog.Parser` for lists. Parses lists which are already
  considered valid key paths. A list is only invalid if it is empty. You might
  want to use lists instead of the string notation if you need to represent
  special values that the parser does not currently support.

  ## Examples

      [42, 3.14] #=> References a map or list with key path [42, 3.14]

      iex> list = ["credentials", "name.first"]
      iex> {:ok, key_path} = Transmog.Parser.parse(list)
      iex> key_path
      ["credentials", "name.first"]

      iex> list = []
      iex> Transmog.Parser.parse(list)
      {:error, :invalid_key_path}

  """

  alias Transmog.InvalidKeyPathError

  @doc """
  `parse/1` parses a list into a key path. A key path is already represented by
  a list and therefore this function will return the list as is unless the list
  is empty. An emtpy list is not a valid key path.

  This is an alternative if you would prefer to pass a key path with special
  values like numbers, strings with periods or colors, etc.

  ## Examples

      iex> list = [1, ":a", %{}]
      iex> {:ok, key_path} = Transmog.Parser.parse(list)
      iex> key_path
      [1, ":a", %{}]

  """
  @spec parse(list :: list(term)) :: {:ok, list(term)} | {:error, :invalid_key_path}
  def parse([]), do: {:error, :invalid_key_path}
  def parse(list) when is_list(list), do: {:ok, list}

  @doc """
  `parse!/1` parses a list into a key path. A key path is already represented by
  a list and therefore this function will return the list as is unless the list
  is empty. If the list is empty then an error will be raised.

  The list will be unwrapped automatically when it is returned.

  ## Examples

      iex> list = [1, nil]
      iex> Transmog.Parser.parse!(list)
      [1, nil]

      iex> list = []
      iex> Transmog.Parser.parse!(list)
      ** (Transmog.InvalidKeyPathError) key path is not valid ([])

  """
  @spec parse!(list :: list(term)) :: list(term)
  def parse!([]), do: InvalidKeyPathError.new([])
  def parse!(list) when is_list(list), do: list
end
