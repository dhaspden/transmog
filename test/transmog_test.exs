defmodule TransmogTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Transmog.InvalidKeyPathError
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

    defmodule TestStruct do
      defstruct [:a, :b]
    end

    test "given a struct, then the keys are transformed into a map" do
      key_paths = [{":a", "a"}, {":b", "b"}]
      source = %TestStruct{a: "a", b: "b"}
      expected = %{"a" => "a", "b" => "b"}

      assert {:ok, result} = Transmog.format(source, key_paths)

      assert result == expected
    end

    test "given nested structs, then each struct is transformed into a map" do
      key_paths = [{":a", "a"}, {":a.:a", "a.a"}]
      source = %TestStruct{a: %TestStruct{a: "a"}}
      expected = %{"a" => %{"a" => "a", b: nil}, b: nil}

      assert {:ok, result} = Transmog.format(source, key_paths)

      assert result == expected
    end
  end

  describe "format!/2" do
    test "when called with a valid key path, then the result is unwrapped" do
      key_paths = [{"a", ":a"}, {"a.b", ":a.:b"}]
      source = %{"a" => %{"b" => "c"}}
      expected = %{a: %{b: "c"}}

      result = Transmog.format!(source, key_paths)

      assert result == expected
    end

    test "when called with a valid key pair struct, then the result is unwrapped" do
      key_paths = [{"a", ":a"}, {"a.b", ":a.:b"}]
      %KeyPairs{} = key_pairs = KeyPairs.parse!(key_paths)
      source = %{"a" => %{"b" => "c"}}
      expected = %{a: %{b: "c"}}

      result = Transmog.format!(source, key_pairs)

      assert result == expected
    end

    test "when called with an invalid key path, then an error is raised" do
      key_paths = [{"", ":a"}]
      source = %{"a" => "b"}

      assert_raise InvalidKeyPathError, fn ->
        Transmog.format!(source, key_paths)
      end
    end
  end
end
