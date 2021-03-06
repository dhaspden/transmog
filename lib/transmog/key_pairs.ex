defmodule Transmog.KeyPairs do
  @moduledoc """
  `Transmog.KeyPairs` is a struct which holds the information about a list of
  `t:key_pair/0` and ensures that they are valid. A key pair is a list of
  mappings from one path to another. For example, `{[:a], [:b]}` indicates that
  we are transforming a map with keys `:a` and `:b` to now have the keys swapped
  with the same values.

  You can create a new `Transmog.KeyPairs` struct manually by calling the
  `new/1` and `new!/1` functions directly. This struct can be used in most of
  the core functionality in this library.

  This library uses `parse/1` and `parse!/1` under the hood to coerce your key
  paths into a format that can be understood by this struct. These functions use
  the `Transmog.Parser` protocol for the type that is provided for the key path.

  ## Examples

      iex> key_pairs = [{[:identity, :first_name], [:user_details, :first_name]}]
      iex> {:ok, %Transmog.KeyPairs{} = key_pairs} = Transmog.KeyPairs.new(key_pairs)
      iex> key_pairs
      %Transmog.KeyPairs{list: [{[:identity, :first_name], [:user_details, :first_name]}]}

      iex> key_pairs = [{[:identity, :first_name], [:user_details, :first_name]}]
      iex> Transmog.KeyPairs.new!(key_pairs)
      %Transmog.KeyPairs{list: [{[:identity, :first_name], [:user_details, :first_name]}]}

  If you do not provide correct key pairs when this struct is created then you
  will receive an `t:invalid/0` error as a response instead.

  ## Examples

      iex> key_pairs = [{nil, [:identity, :last_name]}]
      iex> Transmog.KeyPairs.new(key_pairs)
      {:error, :invalid_key_pairs}

      iex> key_paths = [{nil, ":identity.:last_name"}]
      iex> Transmog.KeyPairs.parse(key_paths)
      {:error, :invalid_key_path} #=> Also possible to receive these errors

      iex> key_pairs = [{nil, [:identity, :last_name]}]
      iex> Transmog.KeyPairs.new!(key_pairs)
      ** (Transmog.InvalidKeyPairsError) key pairs are not valid ({nil, [:identity, :last_name]}, index 0)

      iex> key_paths = [{nil, ":identity.:last_name"}]
      iex> Transmog.KeyPairs.parse!(key_paths)
      ** (Transmog.InvalidKeyPathError) key path is not valid (nil)

  If you know the shape of your data structures in advance then you should
  pre-compile your `Transmog.KeyPairs` structs by calling `parse!/1` or `new!/1`
  and saving the results somewhere where they can be reused.

  `Transmog.format/2` and `Transmog.format!/2` optimize for the case where you
  provide this struct directly.
  """

  alias Transmog.InvalidKeyPairsError
  alias Transmog.Parser

  defstruct list: []

  @typedoc """
  `t:error/0` is the type for when creating a new `Transmog.Keypair` struct
  fails due to either an invalid path or pair.
  """
  @type error :: Parser.error() | invalid

  @typedoc """
  `t:invalid/0` is the type for when a key pair list is determined to not be
  valid the struct is created using `new/1`.
  """
  @type invalid :: {:error, :invalid_key_pairs}

  @typedoc """
  `t:key_pair/0` is the type for a single key pair that is part of the list of
  key pairs that this struct holds.
  """
  @type key_pair :: {list(term), list(term)}

  @typedoc """
  `t:t/0` is the type for the `Transmog.KeyPair` struct.
  """
  @type t :: %__MODULE__{list: list(key_pair)}

  @doc """
  `find_match/2` takes a list of key pairs and a key and finds the pair in the
  list which matches. If a match is found then the opposite key in the key
  pair will be returned as the key that the value should map to.

  ## Examples

      iex> key_pairs = %Transmog.KeyPairs{list: [{[:a], ["a"]}]}
      iex> Transmog.KeyPairs.find_match(key_pairs, [:a])
      ["a"]

      iex> key_pairs = %Transmog.KeyPairs{list: [{[:a], ["a"]}]}
      iex> Transmog.KeyPairs.find_match(key_pairs, [:b])
      [:b]

  """
  @spec find_match(key_pairs :: t, key :: list(term)) :: list(term)
  def find_match(%__MODULE__{list: list}, key) do
    case Enum.find(list, &pair_matches?(key, &1)) do
      nil -> key
      {_, to} -> to
    end
  end

  @doc """
  `new/1` creates a new `Transmog.KeyPairs` struct. It enforces that the key
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

    if valid?(key_pairs) do
      {:ok, %{key_pairs | list: sort_list(list)}}
    else
      invalid_key_pairs()
    end
  end

  def new(_), do: invalid_key_pairs()

  @doc """
  `new!/1` creates a new `Transmog.KeyPairs` struct. It delegates execution to
  `new/1`. If the key pairs are not valid then an error is raised otherwise the
  result is unwrapped and returned.

  ## Examples

      iex> key_pairs = [{[:a, :b], [:b, :a]}]
      iex> Transmog.KeyPairs.new!(key_pairs)
      %Transmog.KeyPairs{list: [{[:a, :b], [:b, :a]}]}

      iex> key_pairs = [{nil, [:a, :b]}]
      iex> Transmog.KeyPairs.new!(key_pairs)
      ** (Transmog.InvalidKeyPairsError) key pairs are not valid ({nil, [:a, :b]}, index 0)

  """
  @spec new!(list :: list(key_pair)) :: t
  def new!(list) when is_list(list) do
    # Validate the pairs one by one so that we can report on the error case
    # specifically in the error message.
    for {pair, index} <- Enum.with_index(list) do
      if !pair_valid?(pair), do: InvalidKeyPairsError.new(pair, index)
    end

    # We know the key pairs are valid because we validate them one by one above
    list
    |> new()
    |> elem(1)
  end

  def new!(_), do: raise(InvalidKeyPairsError)

  @doc """
  `parse/1` takes a list of key paths and attempts to coerce them into valid
  key pairs. If successful then a `Transmog.KeyPair` struct will be returned
  with the key paths converted into the list format.

  ## Examples

      iex> key_paths = [{"a.b", ":a.:b"}]
      iex> {:ok, key_pairs} = Transmog.KeyPairs.parse(key_paths)
      iex> key_pairs
      %Transmog.KeyPairs{list: [{["a", "b"], [:a, :b]}]}

      iex> key_paths = [{"", ":a"}, {"a.b", ":a.:b"}]
      iex> Transmog.KeyPairs.parse(key_paths)
      {:error, :invalid_key_path}

      iex> key_paths = [{"a", ":a.:b"}]
      iex> Transmog.KeyPairs.parse(key_paths)
      {:error, :invalid_key_pairs}

  """
  @spec parse(list :: list(Transmog.key_paths())) :: {:ok, t} | error
  def parse(list) when is_list(list) do
    list =
      list
      |> Enum.reduce({:ok, []}, fn
        {_, _} = pair, {:ok, list} when is_list(list) ->
          case do_parse(pair) do
            {:ok, {left, right} = pair} when is_list(left) and is_list(right) ->
              {:ok, list ++ [pair]}

            {:error, {reason, _}} ->
              {:error, reason}
          end

        _, error ->
          error
      end)

    with {:ok, list} when is_list(list) <- list, do: new(list)
  end

  @doc """
  `parse!/1` takes a list of key paths are coerces them into valid key pairs.
  If the key pairs or any path are not valid then an error will be raised.
  Otherwise the result is unwrapped and returned.

  ## Examples

      iex> key_paths = [{"a.b", ":a.:b"}]
      iex> Transmog.KeyPairs.parse!(key_paths)
      %Transmog.KeyPairs{list: [{["a", "b"], [:a, :b]}]}

      iex> key_paths = [{"", ":a"}, {"a.b", ":a.:b"}]
      iex> Transmog.KeyPairs.parse!(key_paths)
      ** (Transmog.InvalidKeyPathError) key path is not valid (\"\")

      iex> key_paths = [{"a", ":a.:b"}]
      iex> Transmog.KeyPairs.parse!(key_paths)
      ** (Transmog.InvalidKeyPairsError) key pairs are not valid ({[\"a\"], [:a, :b]}, index 0)

  """
  @spec parse!(list :: list(Transmog.key_paths())) :: t
  def parse!(list) do
    list
    |> Enum.reduce([], fn
      {_, _} = pair, list when is_list(list) -> list ++ [do_parse!(pair)]
    end)
    |> new!()
  end

  @doc """
  `reverse/1` takes a `Transmog.KeyPairs` and reverses each individual key pair
  in the list of key pairs. This could be useful if you wanted to reverse a
  format without having to define two separate key pairs manually.

  ## Examples

      iex> key_paths = [{"a", "b"}]
      iex> %Transmog.KeyPairs{} = key_pairs = Transmog.KeyPairs.parse!(key_paths)
      iex> Transmog.KeyPairs.reverse(key_pairs)
      %Transmog.KeyPairs{list: [{["b"], ["a"]}]}

  """
  @spec reverse(key_pairs :: t) :: t
  def reverse(%__MODULE__{list: list} = key_pairs) when is_list(list) do
    list = Enum.map(list, &{elem(&1, 1), elem(&1, 0)})
    %{key_pairs | list: list}
  end

  # Parses a single key path and returns the path if parsing is successful. If
  # parsing fails then the invalid value is returned as well so we can use it
  # when raising an error.
  @spec do_parse(key_path :: term) ::
          {:ok, list(term) | key_pair} | {:error, {:invalid_key_path, term}}
  defp do_parse({left, right}) do
    with {:ok, left} <- do_parse(left),
         {:ok, right} <- do_parse(right) do
      {:ok, {left, right}}
    end
  end

  defp do_parse(key_path) do
    case Parser.parse(key_path) do
      {:ok, _} = result -> result
      {:error, reason} -> {:error, {reason, key_path}}
    end
  end

  # Parses both sides of the key pairs and raises an error if there are any
  # issues with the input.
  @spec do_parse!(key_pairs :: Transmog.key_paths()) :: key_pair
  defp do_parse!({left, right}), do: {Parser.parse!(left), Parser.parse!(right)}

  # Returns an error to indicate that the key pairs are not valid.
  @spec invalid_key_pairs :: invalid
  defp invalid_key_pairs, do: {:error, :invalid_key_pairs}

  # Given a key pair and a key, returns if the key matches the left side of the
  # key pair.
  @spec pair_matches?(key :: list(term), pair :: key_pair) :: boolean
  defp pair_matches?(key, {from, _}) when is_list(key) and is_list(from), do: from == key
  defp pair_matches?(_, _), do: false

  # Returns whether or not a single pair is valid. A pair is considered valid if
  # they are both lists and have the same length.
  @spec pair_valid?(key_pair :: key_pair) :: boolean
  defp pair_valid?({left, right}) when is_list(left) and is_list(right) do
    length(left) == length(right)
  end

  defp pair_valid?(_), do: false

  # Sorts the list of key pairs in order from shortest to longest.
  @spec sort_list(list :: list(key_pair)) :: list(key_pair)
  defp sort_list(list) when is_list(list), do: Enum.sort_by(list, &length(elem(&1, 0)))

  # Returns whether or not all of the key pairs are valid.
  @spec valid?(key_pairs :: t) :: boolean
  defp valid?(%__MODULE__{list: list}) when is_list(list), do: Enum.all?(list, &pair_valid?/1)
  defp valid?(_), do: false
end
