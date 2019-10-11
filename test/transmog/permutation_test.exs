defmodule Transmog.PermutationTest do
  @moduledoc false

  use ExUnit.Case

  alias Transmog.Permutation

  describe "subset/2" do
    test "given a valid list of pairs and key, then a subset is returned" do
      pairs = [{[:a, :b], ["a", "b"]}]
      key = :a
      expected = [{[:b], ["b"]}]

      assert Permutation.subset(pairs, key) == expected
    end
  end
end
