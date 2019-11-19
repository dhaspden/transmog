defmodule Transmog.Parser.AnyTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Transmog.Parser

  describe "parse/1" do
    test "when a value that is not supported is given, then an error is returned" do
      assert {:error, :invalid_key_path} = Parser.parse(nil)
      assert {:error, :invalid_key_path} = Parser.parse(3.14)
    end
  end
end
