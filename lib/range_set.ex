defmodule RangeSet do
  defstruct [:root]

  def new do
    %RangeSet{root: nil}
  end

  def contains?(%RangeSet{root: root}, term), do: do_contains?(root, term)

  defp do_contains?(nil, _), do: false
  defp do_contains?({_, low, _, left, _}, term) when term < low do
    do_contains?(left, term)
  end
  defp do_contains?({_, _, high, _, right}, term) when term > high do
    do_contains?(right, term)
  end
  defp do_contains?(_, _), do: true

  def put(%RangeSet{} = range_set, a, b) when a > b, do: put(range_set, b, a)
  def put(%RangeSet{root: root}, a, b) do
    %RangeSet{root: do_put(root, a, b)}
  end

  defp do_put(nil, a, b), do: {1, a, b, nil, nil}
  defp do_put({_height, low, high, left, right}, a, b) when b < low do
    left = do_put(left, a, b)
    {1 + max(h(left), h(right)), low, high, left, right}
  end
  defp do_put({_height, low, high, left, right}, a, b) when a > high do
    right = do_put(right, a, b)
    {1 + max(h(left), h(right)), low, high, left, right}
  end
  defp do_put({_height, low, high, _left, _right} = node, a, b) when a >= low and b <= high do
    node
  end
  defp do_put({_height, low, high, left, right}, a, b) when a < low and b <= high do
    left = do_put(left, a, low)
    {1 + max(h(left), h(right)), low, high, left, right}
  end
  defp do_put({_height, low, high, left, right}, a, b) when a >= low and b > high do
    right = do_put(right, high, b)
    {1 + max(h(left), h(right)), low, high, left, right}
  end
  defp do_put({_height, low, high, left, right}, a, b) when a < low and b > high do
    left = do_put(left, a, low)
    right = do_put(right, high, b)
    {1 + max(h(left), h(right)), low, high, left, right}
  end

  defp h(nil), do: 0
  defp h({height, _, _, _, _}), do: height
end
