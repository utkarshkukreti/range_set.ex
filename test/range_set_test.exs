defmodule RangeSetTest do
  use ExUnit.Case
  doctest RangeSet

  test "new/0" do
    assert %RangeSet{root: nil} = RangeSet.new
  end

  test "put/3 and contains?/2" do
    # The number of ranges to put in the RangeSet.
    sizes = 1..32
    # The ranges of integers to insert in the RangeSet.
    maximums = [0, 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024]
    # The number of tests to run per size of RangeSet.
    tests = 100
    # The number of random integers to check for contains?/2
    checks = 100

    go = fn ->
      for size <- sizes do
        for maximum <- maximums do
          ranges = for _ <- 1..size, do: Enum.random(0..maximum)..Enum.random(0..maximum)
          range_set = Enum.reduce(ranges, RangeSet.new, fn a..b, range_set ->
            RangeSet.put(range_set, a, b)
          end)
          for integer <- Enum.take_random(1..maximum, checks) do
            # A simple test that's hopefully correct.
            actually_contains = Enum.any?(ranges, fn range -> integer in range end)
            # The above should match RangeSet.contains?/2
            assert actually_contains == RangeSet.contains?(range_set, integer)
          end
        end
      end
    end

    1..tests
    |> Enum.map(fn _ -> Task.async(go) end)
    |> Enum.map(&Task.await/1)
  end
end
