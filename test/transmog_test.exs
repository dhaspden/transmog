defmodule TransmogTest do
  @moduledoc false

  use ExUnit.Case

  describe "format/1" do
    test "given a plain map, then it is formatted completely" do
      values = %{a: "b"}
      pairs = [{":a", "a"}]
      expected = {:ok, %{"a" => "b"}}

      assert Transmog.format(values, pairs) == expected
    end

    test "given a list, then each map is individually formatted" do
      values = [%{a: "a"}, %{a: "b"}]
      pairs = [{":a", "a"}]
      expected = {:ok, [%{"a" => "a"}, %{"a" => "b"}]}

      assert Transmog.format(values, pairs) == expected
    end

    test "given a nested list of maps, then each map is formatted completely" do
      values = [%{a: %{b: "b"}}, %{a: %{b: "c"}}]
      pairs = [{":a", "a"}, {":a.:b", "a.b"}]
      expected = {:ok, [%{"a" => %{"b" => "b"}}, %{"a" => %{"b" => "c"}}]}

      assert Transmog.format(values, pairs) == expected
    end

    test "given multiple nested lists, then each map is formatted completely" do
      value = %{a: [%{b: "c", c: "d"}]}
      formatted_value = %{"a" => [%{"b" => "c", "c" => "d"}]}
      values = [value, value]
      pairs = [{":a", "a"}, {":a.:b", "a.b"}, {":a.:c", "a.c"}]
      expected = {:ok, [formatted_value, formatted_value]}

      assert Transmog.format(values, pairs) == expected
    end

    test "given a value with an integer key, then the value is mapped correctly" do
      values = %{1 => "a"}
      pairs = [{[1], "1"}]
      expected = {:ok, %{"1" => "a"}}

      assert Transmog.format(values, pairs) == expected
    end

    test "given a value with a float key, then the value is mapped correctly" do
      values = %{3.14 => "a"}
      pairs = [{[3.14], [6.28]}]
      expected = {:ok, %{6.28 => "a"}}

      assert Transmog.format(values, pairs) == expected
    end

    test "given a value with a period in the key, then the value is mapped correctly" do
      values = %{"a.b.c" => "a"}
      pairs = [{["a.b.c"], "abc"}]
      expected = {:ok, %{"abc" => "a"}}

      assert Transmog.format(values, pairs) == expected
    end
  end
end
