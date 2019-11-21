defmodule Transmog.KeyPairsTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Transmog.InvalidKeyPairsError
  alias Transmog.InvalidKeyPathError
  alias Transmog.KeyPairs

  doctest Transmog.KeyPairs

  describe "find_match/2" do
    test "when a match is found, then the key is returned" do
      %KeyPairs{} = key_pairs = KeyPairs.parse!([{"a", ":a"}])
      key = ["a"]
      expected = [:a]

      result = KeyPairs.find_match(key_pairs, key)

      assert result == expected
    end

    test "when a match is not found, then the input is returned" do
      %KeyPairs{} = key_pairs = KeyPairs.parse!([{"a", ":a"}])
      key = ["b"]
      expected = key

      result = KeyPairs.find_match(key_pairs, key)

      assert result == expected
    end

    test "in any other case, then the input is returned" do
      key_pairs = %KeyPairs{list: [nil]}
      key = [:a]
      expected = key

      result = KeyPairs.find_match(key_pairs, key)

      assert result == expected
    end
  end

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

  describe "new!/1" do
    test "when the input is valid, then they are stored as is into the struct" do
      list = [{[:a, :b], [:b, :a]}]

      assert %KeyPairs{list: key_pairs} = KeyPairs.new!(list)

      assert list == key_pairs
    end

    test "when the input is of the incorrect type, then an error is raise" do
      assert_raise InvalidKeyPairsError, "key pairs are not valid", fn ->
        KeyPairs.new!(nil)
      end
    end

    test "when there is an invalid key pair, then an error is raise" do
      valid_key_pair = [:a, :b]
      expected = "key pairs are not valid ({[:a, :b], nil}, index 0)"

      assert_raise InvalidKeyPairsError, expected, fn ->
        KeyPairs.new!([{valid_key_pair, nil}])
      end
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

  describe "parse!/1" do
    test "when the input is valid, then a key pairs struct is returned" do
      key_paths = [{"a", ":a"}, {"a.b", ":a.:b"}]
      expected = [{["a"], [:a]}, {["a", "b"], [:a, :b]}]

      assert %KeyPairs{list: key_pairs} = KeyPairs.parse!(key_paths)

      assert key_pairs == expected
    end

    test "when a key path is not valid, then an error is returned" do
      expected = "key path is not valid (\"\")"

      assert_raise InvalidKeyPathError, expected, fn ->
        KeyPairs.parse!([{"", ":a"}, {"a.b", ":a.:b"}])
      end
    end
  end

  describe "reverse/1" do
    test "when a key pair is given, then the list is reversed" do
      key_paths = [{"a", ":a"}, {"a.b", ":a.:b"}]
      expected = [{[:a], ["a"]}, {[:a, :b], ["a", "b"]}]
      %KeyPairs{} = key_pairs = KeyPairs.parse!(key_paths)

      assert %KeyPairs{list: key_pairs} = KeyPairs.reverse(key_pairs)

      assert key_pairs == expected
    end
  end
end
