defmodule Transmog.Parser do
  @moduledoc false

  def parse(pairs) when is_list(pairs) do
    case Enum.reduce_while(pairs, [], &parse_pair/2) do
      {:error, _} = error -> error
      pairs -> {:ok, pairs}
    end
  end

  defp from_string(path) when is_binary(path) do
    path
    |> String.split(".")
    |> Enum.map(&parse_field/1)
  end

  defp parse_field(":" <> field) when is_binary(field), do: String.to_existing_atom(field)
  defp parse_field(field) when is_binary(field), do: field

  defp parse_pair({from, to}, pairs) when is_binary(from) and is_binary(to) do
    {:cont, pairs ++ [{from_string(from), from_string(to)}]}
  end

  defp parse_pair(_, _), do: {:halt, {:error, :invalid_pair}}
end
