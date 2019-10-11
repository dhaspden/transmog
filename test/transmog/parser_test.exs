defmodule Transmog.ParserTest do
  @moduledoc false

  use ExUnit.Case

  alias Transmog.Parser

  describe "parse/1" do
    test "given a valid list of pairs, then a list of Parsers are returned" do
      input = [{":a.b", "a.b"}]
      expected = [{[:a, "b"], ["a", "b"]}]

      assert {:ok, output} = Parser.parse(input)

      assert output == expected
    end

    test "given an invalid pair, then an error is returned" do
      input = [{nil, "a.b"}]

      assert {:error, :invalid_pair} = Parser.parse(input)
    end
  end
end
