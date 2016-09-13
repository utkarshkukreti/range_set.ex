defmodule RangeSetTest do
  use ExUnit.Case
  doctest RangeSet

  test "new/0" do
    assert %RangeSet{root: nil} = RangeSet.new
  end
end
