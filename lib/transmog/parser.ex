defmodule Transmog.Parser do
  @moduledoc false

  @type error :: {:error, :invalid_pair}

  @spec parse(pairs :: [Transmog.raw_pair()]) :: {:ok, [Transmog.pair()]} | error
  def parse(pairs) when is_list(pairs) do
    case Enum.reduce_while(pairs, [], &parse_pair/2) do
      {:error, _} = error -> error
      pairs -> {:ok, pairs}
    end
  end

  @spec valid?(pairs :: [Transmog.pair()]) :: boolean
  def valid?(pairs) when is_list(pairs), do: Enum.all?(pairs, &valid_pair?/1)

  @spec from_string(path :: binary) :: [Transmog.key()]
  defp from_string(path) when is_binary(path) do
    path
    |> String.split(".")
    |> Enum.map(&parse_field/1)
  end

  @spec parse_field(field :: binary) :: Transmog.key()
  defp parse_field(":" <> field) when is_binary(field), do: String.to_existing_atom(field)
  defp parse_field(field) when is_binary(field), do: field

  @spec parse_pair(pair :: Transmog.pair(), pairs :: [Transmog.pair()]) ::
          {:cont, [Transmog.pair()]} | {:halt, error}
  defp parse_pair({from, to}, pairs) when is_binary(from) and is_binary(to) do
    {:cont, pairs ++ [{from_string(from), from_string(to)}]}
  end

  defp parse_pair(_, _), do: {:halt, {:error, :invalid_pair}}

  @spec valid_field?(field :: Transmog.key()) :: boolean
  defp valid_field?(field) when is_atom(field) or is_binary(field), do: true
  defp valid_field?(_), do: false

  @spec valid_pair?(pair :: Transmog.pair()) :: boolean
  defp valid_pair?({from, to}) when is_list(from) and is_list(to) do
    length(from) == length(to) && Enum.all?(from ++ to, &valid_field?/1)
  end

  defp valid_pair?(_), do: false
end
