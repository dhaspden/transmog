defmodule Transmog.Matcher do
  @moduledoc false

  def find(pairs, key) when is_list(pairs) and (is_atom(key) or is_binary(key)) do
    match =
      Enum.find(pairs, fn
        {[from], [_]} -> from == key
        _ -> false
      end)

    case match do
      nil -> key
      {[_], [to]} -> to
    end
  end
end
