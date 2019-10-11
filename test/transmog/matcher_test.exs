defmodule Transmog.MatcherTest do
  @moduledoc false

  use ExUnit.Case

  alias Transmog.Matcher

  describe "find/2" do
    test "when a match is found, then it is returned" do
      pairs = [{[:a], ["a"]}]
      key = :a
      expected = "a"

      assert Matcher.find(pairs, key) == expected
    end

    test "when no match is found, then the original key is returned" do
      pairs = [{[:a], ["a"]}]
      key = :b
      expected = :b

      assert Matcher.find(pairs, key) == expected
    end
  end
end
