defmodule Transmog.Parser.BitStringTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Transmog.Parser

  describe "parse/1" do
    test "when an atom is in the string, then it is converted to an atom safely" do
      string = ":a"
      expected = [:a]

      assert {:ok, key_path} = Parser.parse(string)

      assert key_path == expected
    end

    test "when the string contains no atoms, then the path consists of strings" do
      string = "a"
      expected = ["a"]

      assert {:ok, key_path} = Parser.parse(string)

      assert key_path == expected
    end

    test "when the string contains multiple values, then they are parsed individually" do
      string = "a.:b"
      expected = ["a", :b]

      assert {:ok, key_path} = Parser.parse(string)

      assert key_path == expected
    end

    test "when an empty string is given, then an error is returned" do
      string = ""

      assert {:error, :invalid_key_path} = Parser.parse(string)
    end
  end
end
