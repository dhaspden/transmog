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
end
