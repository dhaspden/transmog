defmodule Transmog.InvalidKeyPairsError do
  defexception message: "key pairs are not valid"

  @doc """
  `new/1` raises an error with a custom field added to the error message.

  ## Examples

      iex> Transmog.InvalidKeyPairsError.new(nil)
      ** (Transmog.InvalidKeyPairsError) key pairs are not valid (nil)

  """
  @spec new(field :: term) :: no_return
  def new(field) do
    message = "key pairs are not valid (#{inspect(field)})"
    raise __MODULE__, message: message
  end

  @doc """
  `new/2` raises an error with a custom field and index added to the error
  message.

  ## Examples

      iex> Transmog.InvalidKeyPairsError.new(nil, 1)
      ** (Transmog.InvalidKeyPairsError) key pairs are not valid (nil, index 1)

  """
  @spec new(field :: term, index :: non_neg_integer) :: no_return
  def new(field, index) when is_integer(index) do
    message = "key pairs are not valid (#{inspect(field)}, index #{index})"
    raise __MODULE__, message: message
  end
end
