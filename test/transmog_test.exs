defmodule TransmogTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Transmog.KeyPairs

  doctest Transmog

  describe "format/2" do
    test "given a map, then the keys are transformed" do
      key_paths = [{"a", ":a"}, {"a.b", ":a.:b"}]
      source = %{"a" => %{"b" => "c"}}
      expected = %{a: %{b: "c"}}

      assert {:ok, result} = Transmog.format(source, key_paths)

      assert result == expected
    end

    test "given a map with a nested list, then the keys are transformed" do
      key_paths = [{"a", ":a"}, {"a.b", ":a.:b"}]
      source = %{"a" => [%{"b" => "c"}, %{"b" => "d"}]}
      expected = %{a: [%{b: "c"}, %{b: "d"}]}

      assert {:ok, result} = Transmog.format(source, key_paths)

      assert result == expected
    end

    test "given a list with a nested map, then the keys are transformed" do
      key_paths = [{"a", ":a"}, {"a.b", ":a.:b"}]
      source = [%{"a" => %{"b" => "c"}}, %{"a" => %{"b" => "d"}}]
      expected = [%{a: %{b: "c"}}, %{a: %{b: "d"}}]

      assert {:ok, result} = Transmog.format(source, key_paths)

      assert result == expected
    end

    test "given a list with multiple nested maps, then the keys are transformed" do
      key_paths = [{"a", ":a"}, {"a.b", ":a.:b"}, {"a.b.c", ":a.:b.:c"}]
      source = [%{"a" => %{"b" => %{"c" => "d"}}}, %{"a" => %{"b" => %{"c" => "e"}}}]
      expected = [%{a: %{b: %{c: "d"}}}, %{a: %{b: %{c: "e"}}}]

      assert {:ok, result} = Transmog.format(source, key_paths)

      assert result == expected
    end

    test "given an invalid key path, then an error is returned" do
      key_paths = [{"", ":a"}]
      source = %{"a" => "b"}

      assert {:error, :invalid_key_path} = Transmog.format(source, key_paths)
    end

    test "given an unknown key, then it is skipped in the result" do
      key_paths = [{"a", ":a"}, {"a.b", ":a.:b"}]
      source = %{"a" => "b"}
      expected = %{a: "b"}

      assert {:ok, result} = Transmog.format(source, key_paths)

      assert result == expected
    end

    test "given key pairs directly, then the keys are transformed" do
      key_paths = [{"a", ":a"}, {"a.b", ":a.:b"}]
      {:ok, %KeyPairs{} = key_pairs} = KeyPairs.parse(key_paths)
      source = %{"a" => %{"b" => "c"}}
      expected = %{a: %{b: "c"}}

      assert {:ok, result} = Transmog.format(source, key_pairs)

      assert result == expected
    end
  end
end
