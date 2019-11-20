defprotocol Transmog.Parser do
  @moduledoc """
  `Transmog.Protocol` defines how to parse a single key path. Parsing a key path
  means to transform it into a list which defines how to reach the target value
  in the nested map or list.

  ## Examples

      "a.:b.c" #=> References a map or list with key path ["a", :b, "c"]
      ":a.1" #=> References a map or list with key path [:a, "1"]

  Currently the following types are supported by this library:

  * `binary`
  * `nonempty_list(term)`

  ## Examples

      iex> string = "credentials.:first_name"
      iex> {:ok, key_path} = Transmog.Parser.parse(string)
      iex> key_path
      ["credentials", :first_name]

      iex> string = ""
      iex> Transmog.Parser.parse(string)
      {:error, :invalid_key_path}

  """

  @typedoc """
  `t:error/0` is the type for the error that the parser should return if it
  encounters a value that is not valid.
  """
  @type error :: {:error, :invalid_key_path}

  @fallback_to_any true

  @doc """
  `parse/1` will convert a value into a valid key path. If applicable and the
  value is not valid, then a value of `t:error/0` will be returned instead.
  """
  @spec parse(data :: t) :: {:ok, list(term)} | error
  def parse(data)
end
