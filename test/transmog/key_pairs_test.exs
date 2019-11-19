defmodule Transmog.KeyPairsTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Transmog.KeyPairs

  doctest Transmog.KeyPairs

  describe "new/1" do
    test "when the input is valid, then they are stored as is into the struct" do
      list = [{[:a, :b], [:b, :a]}]

      assert {:ok, %KeyPairs{list: key_pairs}} = KeyPairs.new(list)

      assert list == key_pairs
    end

    test "when multiple key pairs are given, then they are sorted by length" do
      list = [{[:a, :b], [:b, :a]}, {[:a], [:b]}]
      expected = [{[:a], [:b]}, {[:a, :b], [:b, :a]}]

      assert {:ok, %KeyPairs{list: key_pairs}} = KeyPairs.new(list)

      assert key_pairs == expected
    end

    test "when the input is of the incorrect type, then an error is returned" do
      assert {:error, :invalid_key_pairs} = KeyPairs.new(nil)
      assert {:error, :invalid_key_pairs} = KeyPairs.new("string")
      assert {:error, :invalid_key_pairs} = KeyPairs.new(true)
      assert {:error, :invalid_key_pairs} = KeyPairs.new(%{})
      assert {:error, :invalid_key_pairs} = KeyPairs.new(<<>>)
    end

    test "when there is an invalid key pair, then an error is returned" do
      valid_key_pair = [:a, :b]

      assert {:error, :invalid_key_pairs} = KeyPairs.new([{valid_key_pair, nil}])
      assert {:error, :invalid_key_pairs} = KeyPairs.new([{nil, valid_key_pair}])
    end
  end

  describe "parse/1" do
    test "when the input is valid, then a key pairs struct is returned" do
      key_paths = [{"a", ":a"}, {"a.b", ":a.:b"}]
      expected = [{["a"], [:a]}, {["a", "b"], [:a, :b]}]

      assert {:ok, %KeyPairs{list: key_pairs}} = KeyPairs.parse(key_paths)

      assert key_pairs == expected
    end

    test "when a key path is not valid, then an error is returned" do
      assert {:error, :invalid_key_path} = KeyPairs.parse([{"", ":a"}, {"a.b", ":a.:b"}])
      assert {:error, :invalid_key_path} = KeyPairs.parse([{"a", ":a"}, {"a.b", ""}])
    end
  end
end
