defmodule Transmog.KeyPairs do
  @moduledoc """
  `Transmog.KeyPairs` is a struct which holds the information about key pairs
  and ensures that they are valid. A key pair is a list of mappings from one
  path to another. For example, `{[:a, :b], [:b, :a]}` indicates that we are
  transforming a map with keys `:a` and `:b` to now have the keys swapped with
  the same values.

  You can create a new `%Transmog.KeyPairs{}` struct manually by calling the
  `new/1` function directly. This struct can be used in most of the core
  functionality in this library.

  ## Examples

      iex> key_pairs = [{[:identity, :first_name], [:user_details, :first_name]}]
      iex> {:ok, %Transmog.KeyPairs{} = key_pairs} = Transmog.KeyPairs.new(key_pairs)
      iex> key_pairs
      %Transmog.KeyPairs{list: [{[:identity, :first_name], [:user_details, :first_name]}]}

  If you do not provide correct key pairs when this struct is created then you
  will receive a validation error as a response instead.

  ## Examples

      iex> key_pairs = [{nil, [:identity, :last_name]}]
      iex> Transmog.KeyPairs.new(key_pairs)
      {:error, :invalid_key_pairs}

  """

  defstruct list: []

  @typedoc """
  `invalid` is the type for when a key pair list is determined to not be valid
  the struct is created using `new/1`.
  """
  @type invalid :: {:error, :invalid_key_pairs}

  @typedoc """
  `key_pair` is the type for a single key pair that is part of the list of key
  pairs that this struct holds.
  """
  @type key_pair :: {list(term), list(term)}

  @typedoc """
  `t` is the type for the `Transmog.KeyPair` struct.
  """
  @type t :: %__MODULE__{list: list(key_pair)}

  @doc """
  `new/1` creates a new `%Transmog.KeyPairs{}` struct. It enforces that the key
  pairs are valid and have been previously parsed. If the key pairs are not
  valid then an error will be returned.

  ## Examples

      iex> key_pairs = [{[:a, :b], [:b, :a]}]
      iex> {:ok, key_pairs} = Transmog.KeyPairs.new(key_pairs)
      iex> key_pairs
      %Transmog.KeyPairs{list: [{[:a, :b], [:b, :a]}]}

      iex> key_pairs = [{nil, [:a, :b]}]
      iex> Transmog.KeyPairs.new(key_pairs)
      {:error, :invalid_key_pairs}

  """
  @spec new(list :: list(key_pair)) :: {:ok, t} | invalid
  def new(list) when is_list(list) do
    key_pairs = %__MODULE__{list: list}
    if valid?(key_pairs), do: {:ok, key_pairs}, else: invalid_key_pairs()
  end

  def new(_), do: invalid_key_pairs()

  # Returns an error to indicate that the key pairs are not valid.
  @spec invalid_key_pairs :: invalid
  defp invalid_key_pairs, do: {:error, :invalid_key_pairs}

  # Returns whether or not a single pair is valid. A pair is considered valid if
  # they are both lists and have the same length.
  @spec pair_valid?(key_pair :: key_pair) :: boolean
  defp pair_valid?({left, right}) when is_list(left) and is_list(right) do
    length(left) == length(right)
  end

  defp pair_valid?(_), do: false

  # Returns whether or not all of the key pairs are valid.
  @spec valid?(key_pairs :: t) :: boolean
  defp valid?(%__MODULE__{list: list}) when is_list(list), do: Enum.all?(list, &pair_valid?/1)
  defp valid?(_), do: false
end
