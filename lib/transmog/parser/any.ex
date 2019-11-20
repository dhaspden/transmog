defimpl Transmog.Parser, for: Any do
  @moduledoc """
  Fallback implement of `Transmog.Parser`. These values are all considered
  invalid and will always return an error.

  ## Examples

      iex> value = 3.14
      iex> Transmog.Parser.parse(value)
      {:error, :invalid_key_path}

      iex> value = 42
      iex> Transmog.Parser.parse!(value)
      ** (Transmog.InvalidKeyPathError) key path is not valid (42)

  """

  alias Transmog.InvalidKeyPathError
  alias Transmog.Parser

  @doc """
  `parse/1` is the fallback implementation for any type that is not implemented
  by the parser. These values are all invalid by default. This function will
  always return an error tuple.

  If you want the value to be parsed then your only options are to either use
  the built in parsers or implement your own.

  ## Examples

      iex> value = nil
      iex> Transmog.Parser.parse(value)
      {:error, :invalid_key_path}

  """
  @spec parse(value :: term) :: Parser.error()
  def parse(_), do: {:error, :invalid_key_path}

  @doc """
  `parse!/1` is the fallback implementation for any type that is not implemented
  by the parser. In this case an error will be raised with a message which
  describes the value that is invalid.

  ## Examples

      iex> value = nil
      iex> Transmog.Parser.parse!(value)
      ** (Transmog.InvalidKeyPathError) key path is not valid (nil)

  """
  @spec parse!(value :: term) :: no_return
  def parse!(value), do: InvalidKeyPathError.new(value)
end
