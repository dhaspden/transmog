defmodule Transmog do
  @moduledoc false

  alias Transmog.KeyPairs

  @doc """
  `format/2` takes a source value and either a list of key paths or a
  `%Transmog.KeyPair{}` struct directly and performs the key transformation
  on the value.

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
  @spec format(source :: term, key_pairs :: KeyPairs.t) :: term
  def format(source, %KeyPairs{} = key_pairs), do: {:ok, do_format(source, key_pairs)}

  def format(source, key_paths) do
    with {:ok, %KeyPairs{} = key_pairs} <- KeyPairs.parse(key_paths) do
      format(source, key_pairs)
    end
  end

  # Formats a single level of a map or list. If the input is a list then the
  # formatter is run over each map in the list. If the input is a map then each
  # key is formatted and each value has `do_format/3` called on it.
  @spec do_format(source :: term, key_pairs :: KeyPairs.t(), prefix :: list(term)) :: term
  defp do_format(source, key_pairs, prefix \\ [])

  defp do_format(source, %KeyPairs{} = key_pairs, prefix) when is_list(source) do
    Enum.map(source, &do_format(&1, key_pairs, prefix))
  end

  defp do_format(%{} = source, %KeyPairs{} = key_pairs, prefix) when is_list(prefix) do
    for {key, value} <- source, into: %{} do
      current_path = prefix ++ [key]
      {match_path(key_pairs, current_path), do_format(value, key_pairs, current_path)}
    end
  end

  defp do_format(source, _, _), do: source

  @spec match_path(key_pairs :: KeyPairs.t, path :: list(term)) :: term
  defp match_path(%KeyPairs{} = key_pairs, path) do
    key_pairs
    |> KeyPairs.find_match(path)
    |> Enum.reverse()
    |> hd()
  end
end
