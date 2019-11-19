defmodule Transmog.Parser.ListTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Transmog.Parser

  doctest Transmog.Parser

  describe "parse/1" do
    test "when the list is not empty, then it is returned as is" do
      list = [:a, :b]
      expected = [:a, :b]

      assert {:ok, key_path} = Parser.parse(list)

      assert key_path == expected
    end

    test "when the list is empty, then an error is returned" do
      assert {:error, :invalid_key_path} = Parser.parse([])
    end
  end
end
