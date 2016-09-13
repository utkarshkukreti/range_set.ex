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
    n(low, high, left, right) |> do_balance
  end
  defp do_put({_height, low, high, left, right}, a, b) when a > high do
    right = do_put(right, a, b)
    n(low, high, left, right) |> do_balance
  end
  defp do_put({_height, low, high, _left, _right} = node, a, b) when a >= low and b <= high do
    node
  end
  defp do_put({_height, low, high, left, right}, a, b) when a < low and b <= high do
    left = do_put(left, a, low)
    n(low, high, left, right) |> do_balance
  end
  defp do_put({_height, low, high, left, right}, a, b) when a >= low and b > high do
    right = do_put(right, high, b)
    n(low, high, left, right) |> do_balance
  end
  defp do_put({_height, low, high, left, right}, a, b) when a < low and b > high do
    left = do_put(left, a, low)
    right = do_put(right, high, b)
    n(low, high, left, right) |> do_balance
  end

  defp do_rotate_left({_, low, high, left, {_, rlow, rhigh, rleft, rright}}) do
    n(rlow, rhigh, n(low, high, left, rleft), rright)
  end

  defp do_rotate_right({_, low, high, {_, llow, lhigh, lleft, lright}, right}) do
    n(llow, lhigh, lleft, n(low, high, lright, right))
  end

  defp do_balance(nil), do: nil
  defp do_balance({_, low, high, left, right} = node) do
    case h(left) - h(right) do
      2 ->
        {lheight, llow, lhigh, lleft, lright} = left
        if h(lleft) - h(lright) > -1 do
          # Left Left
          node
        else
          # Left Right
          n(low, high, left |> do_rotate_left, right)
        end |> do_rotate_right
      -2 ->
        {rheight, rlow, rhigh, rleft, rright} = right
        if h(rleft) - h(rright) < 1 do
          # Right Right
          node
        else
          # Right Left
          n(low, high, left, right |> do_rotate_right)
        end |> do_rotate_left
      _ ->
        node
    end
  end

  defp h(nil), do: 0
  defp h({height, _, _, _, _}), do: height

  defp n(low, high, left, right) do
    {1 + max(h(left), h(right)), low, high, left, right}
  end
end
