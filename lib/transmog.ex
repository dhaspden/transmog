defmodule Transmog do
  @moduledoc """
  `Transmog` is a module which provides the ability to map keys on nested maps,
  lists and structs to new values. It is useful for when you have external data
  that you want to convert into an internal format easily. This recursive
  transformation is made using an internal concept known as key pairs.

  ## Key Pairs

  Key pairs are a list of two-tuples which represent a mapping from a key in the
  source map to a key in the destination map. The key mapping does not have to
  be exhaustive and any values that are skipped are simply added to the result.

  ## Examples

      #=> "credentials", "first_name" to :identity, :first_name
      [{["credentials", "first_name"], [:identity, :first_name]}]

  When key pairs are simple they can be represented using an internal DSL which
  is a dot notation string. These dot notation strings also support atoms if you
  prefix them with `:`.

  ## Examples

      #=> Same as the previous example
      [{"credentials.first_name", ":identity.:first_name"}]

  ## Parsing

  All of the supported key pair formats implement the `Transmog.Parser`
  protocol. Technically if you wanted to add support for a different type then
  you could implement the protocol for them.

  ## Formatting

  We validate key pairs when they are provided to the main entrypoint of the
  library, `format/2` and `format!/2`. If the key pairs are not valid then we
  will let you know with an error.

  ## Examples

      #=> Notice: key paths must be equal length!
      iex> key_paths = [{"credentials", ":identity.:first_name"}]
      iex> Transmog.format(%{"credentials" => "Mike Rudolph"}, key_paths)
      {:error, :invalid_key_pairs}

      iex> key_paths = [{"", ":last_name"}]
      iex> Transmog.format(%{}, key_paths)
      {:error, :invalid_key_path}

  Once your key pairs are validated you can start to use them to transform your
  nested maps and lists.

  ## Examples

      #=> Notice: you need to be explicit about which keys you want updated
      iex> key_paths = [
      ...>   {"credentials", ":identity"},
      ...>   {"credentials.first_name", ":identity.:first_name"}
      ...> ]
      iex> source = %{"credentials" => %{"first_name" => "Tom"}}
      iex> {:ok, result} = Transmog.format(source, key_paths)
      iex> result
      %{identity: %{first_name: "Tom"}}

      iex> key_paths = [
      ...>   {"credentials", ":identity"},
      ...>   {"credentials.first_name", ":identity.:first_name"}
      ...> ]
      iex> source = [
      ...>   %{"credentials" => %{"first_name" => "John"}},
      ...>   %{"credentials" => %{"first_name" => "Sally"}}
      ...> ]
      iex> {:ok, result} = Transmog.format(source, key_paths)
      iex> result
      [%{identity: %{first_name: "John"}}, %{identity: %{first_name: "Sally"}}]

  If you know that your key pairs are valid then you can use `format!/2` instead
  and your results will be unwrapped automatically for you.

  ## Examples

      iex> key_paths = [{"name", ":name"}]
      iex> source = %{"name" => "Jimmy"}
      iex> Transmog.format!(source, key_paths)
      %{name: "Jimmy"}

  You can even transform your structs. When a struct is encountered during the
  parse it will be converted into a map automatically for you.
  """

  alias Transmog.KeyPairs

  @typedoc """
  `t:key_paths/0` is the type for a single tuple of key paths. Both sides can
  be any type as long as they can be parsed by `Transmog.Parser`.
  """
  @type key_paths :: {term, term}

  @doc """
  `format/2` takes a source value and either a list of key paths or a
  `Transmog.KeyPair` struct directly and performs the key transformation on the
  value.

  If the key paths are given then they will be parsed using
  `Transmog.KeyPairs.parse/1` and will report errors if any occur during that.

  ## Examples

      iex> key_paths = [{"a", ":a"}, {"a.b", ":a.:b"}]
      iex> source = %{"a" => %{"b" => "c"}}
      iex> {:ok, result} = Transmog.format(source, key_paths)
      iex> result
      %{a: %{b: "c"}}

      iex> key_paths = [{"a", ":a"}, {"a.b", ":a.:b"}]
      iex> {:ok, %Transmog.KeyPairs{} = key_pairs} = Transmog.KeyPairs.parse(key_paths)
      iex> source = %{"a" => %{"b" => "c"}}
      iex> {:ok, result} = Transmog.format(source, key_pairs)
      iex> result
      %{a: %{b: "c"}}

  """
  @spec format(source :: term, mapping :: KeyPairs.t() | list(key_paths)) ::
          {:ok, term} | KeyPairs.error()
  def format(source, %KeyPairs{} = key_pairs), do: {:ok, do_format(source, key_pairs)}

  def format(source, key_paths) do
    with {:ok, %KeyPairs{} = key_pairs} <- KeyPairs.parse(key_paths) do
      format(source, key_pairs)
    end
  end

  @doc """
  `format!/2` takes a source value and either a list of key paths or a
  `Transmog.KeyPair` struct directly and performs the key transformation on the
  value.

  This function will raise an error if the `Transmog.KeyPair` struct cannot be
  created by parsing the key paths. The result will be automatically unwrapped
  if the operation is successful.

  ## Examples

      iex> key_paths = [{"a", ":a"}, {"a.b", ":a.:b"}]
      iex> source = %{"a" => %{"b" => "c"}}
      iex> Transmog.format!(source, key_paths)
      %{a: %{b: "c"}}

      iex> key_paths = [{"a", ":a"}, {"a.b", ":a.:b"}]
      iex> %Transmog.KeyPairs{} = key_pairs = Transmog.KeyPairs.parse!(key_paths)
      iex> source = %{"a" => %{"b" => "c"}}
      iex> Transmog.format!(source, key_pairs)
      %{a: %{b: "c"}}

  """
  @spec format!(source :: term, mapping :: KeyPairs.t() | list(key_paths)) :: term
  def format!(source, %KeyPairs{} = key_pairs), do: do_format(source, key_pairs)

  def format!(source, key_paths) do
    %KeyPairs{} = key_pairs = KeyPairs.parse!(key_paths)
    format!(source, key_pairs)
  end

  # Formats a single level of a map or list. If the input is a list then the
  # formatter is run over each map in the list. If the input is a map then each
  # key is formatted and each value has `do_format/3` called on it.
  @spec do_format(source :: term, key_pairs :: KeyPairs.t(), prefix :: list(term)) :: term
  defp do_format(source, key_pairs, prefix \\ [])

  defp do_format(source, %KeyPairs{} = key_pairs, prefix) when is_list(source) do
    Enum.map(source, &do_format(&1, key_pairs, prefix))
  end

  defp do_format(%_{} = source, %KeyPairs{} = key_pairs, prefix) when is_list(prefix) do
    source
    |> Map.from_struct()
    |> do_format(key_pairs, prefix)
  end

  defp do_format(%{} = source, %KeyPairs{} = key_pairs, prefix) when is_list(prefix) do
    for {key, value} <- source, into: %{} do
      current_path = prefix ++ [key]
      {match_path(key_pairs, current_path), do_format(value, key_pairs, current_path)}
    end
  end

  defp do_format(source, _, _), do: source

  # Given the key pairs and path, attempts to find a match in the key pairs
  # list. If no match is found then the key that was passed will be returned.
  # Because we know the list isn't empty and that we fallback to the passed
  # key, we know that `hd/1` should never raise.
  @spec match_path(key_pairs :: KeyPairs.t(), path :: nonempty_list(term)) :: term
  defp match_path(%KeyPairs{} = key_pairs, path) when is_list(path) do
    key_pairs
    |> KeyPairs.find_match(path)
    |> Enum.reverse()
    |> hd()
  end
end
