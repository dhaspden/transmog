defmodule Transmog.InvalidKeyPathError do
  defexception message: "key path is not valid"

  @doc """
  `new/1` raises an error with a custom field added to the error message.

  ## Examples

      iex> Transmog.InvalidKeyPathError.new(nil)
      ** (Transmog.InvalidKeyPathError) key path is not valid (nil)

  """
  @spec new(field :: term) :: no_return
  def new(field) do
    message = "key path is not valid (#{inspect(field)})"
    raise __MODULE__, message: message
  end
end
