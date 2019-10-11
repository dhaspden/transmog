defmodule Transmog.Parser do
  @moduledoc false

  def parse(pairs) when is_list(pairs) do
    pairs =
      Enum.reduce_while(pairs, [], fn
        {from, to}, acc when is_binary(from) and is_binary(to) ->
          {:cont, acc ++ [{from_string(from), from_string(to)}]}

        _, _ ->
          {:halt, {:error, :invalid_pair}}
      end)

    case pairs do
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
end
