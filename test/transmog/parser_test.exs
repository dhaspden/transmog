defmodule Transmog.ParserTest do
  @moduledoc false

  use ExUnit.Case

  alias Transmog.Parser

  describe "parse/1" do
    test "given a valid list of pairs, then a list of parsers are returned" do
      input = [{":a.b", "a.b"}]
      expected = [{[:a, "b"], ["a", "b"]}]

      assert {:ok, output} = Parser.parse(input)

      assert output == expected
    end

    test "given an invalid pair, then an error is returned" do
      input = [{nil, "a.b"}]

      assert {:error, :invalid_pair} = Parser.parse(input)
    end

    test "given a pre-defined path, then the path is returned as is" do
      input = [{[:a, "b"], "a.b"}]
      expected = [{[:a, "b"], ["a", "b"]}]

      assert {:ok, output} = Parser.parse(input)

      assert output == expected
    end
  end

  describe "valid?/1" do
    test "given a valid list of pairs, then true is returned" do
      input = [{[:a, "b"], ["a", "b"]}]

      assert Parser.valid?(input)
    end

    test "when the first pair is invalid, then false is returned" do
      input = [{nil, ["a", "b"]}]

      refute Parser.valid?(input)
    end

    test "when the second pair is invalid, then false is returned" do
      input = [{[:a, "b"], nil}]

      refute Parser.valid?(input)
    end

    test "when pairs have a different length, then false is returned" do
      input = [{[:a, "b"], ["b"]}]

      refute Parser.valid?(input)
    end

    test "when any other value is given, then false is returned" do
      input = fn -> nil end

      refute Parser.valid?(input)
    end
  end
end
