defmodule Transmog.Parser.AnyTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Transmog.InvalidKeyPathError
  alias Transmog.Parser

  describe "parse/1" do
    test "when a value that is not supported is given, then an error is returned" do
      assert {:error, :invalid_key_path} = Parser.parse(nil)
      assert {:error, :invalid_key_path} = Parser.parse(3.14)
    end
  end

  describe "parse!/1" do
    test "when a value that is not supported is given, then an error is raised" do
      expected = "key path is not valid (nil)"

      assert_raise InvalidKeyPathError, expected, fn ->
        Parser.parse!(nil)
      end
    end
  end
end
