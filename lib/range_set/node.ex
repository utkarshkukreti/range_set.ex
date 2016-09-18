defmodule RangeSet.Node do
  def new do
    nil
  end

  def new(low, high, left, right) do
    {1 + max(height(left), height(right)), low, high, left, right}
  end

  def contains?(nil, _), do: false
  def contains?({_, low, _, left, _}, term) when term < low do
    contains?(left, term)
  end
  def contains?({_, _, high, _, right}, term) when term > high do
    contains?(right, term)
  end
  def contains?(_, _), do: true

  def put(nil, a, b), do: {1, a, b, nil, nil}
  def put({_height, low, high, left, right}, a, b) when b < low do
    left = put(left, a, b)
    new(low, high, left, right) |> balance
  end
  def put({_height, low, high, left, right}, a, b) when a > high do
    right = put(right, a, b)
    new(low, high, left, right) |> balance
  end
  def put({_height, low, high, _left, _right} = node, a, b) when a >= low and b <= high do
    node
  end
  def put({_height, low, high, left, right}, a, b) when a < low and b <= high do
    left = put(left, a, low)
    new(low, high, left, right) |> balance
  end
  def put({_height, low, high, left, right}, a, b) when a >= low and b > high do
    right = put(right, high, b)
    new(low, high, left, right) |> balance
  end
  def put({_height, low, high, left, right}, a, b) when a < low and b > high do
    left = put(left, a, low)
    right = put(right, high, b)
    new(low, high, left, right) |> balance
  end

  def rotate_left({_, low, high, left, {_, rlow, rhigh, rleft, rright}}) do
    new(rlow, rhigh, new(low, high, left, rleft), rright)
  end

  def rotate_right({_, low, high, {_, llow, lhigh, lleft, lright}, right}) do
    new(llow, lhigh, lleft, new(low, high, lright, right))
  end

  def balance(nil), do: nil
  def balance({_, low, high, left, right} = node) do
    case height(left) - height(right) do
      2 ->
        {lheight, llow, lhigh, lleft, lright} = left
        if height(lleft) - height(lright) >= 0 do
          # Left Left
          node
        else
          # Left Right
          new(low, high, left |> rotate_left, right)
        end |> rotate_right
      -2 ->
        {rheight, rlow, rhigh, rleft, rright} = right
        if height(rleft) - height(rright) <= 0 do
          # Right Right
          node
        else
          # Right Left
          new(low, high, left, right |> rotate_right)
        end |> rotate_left
      _ ->
        node
    end
  end

  def height(nil), do: 0
  def height({height, _, _, _, _}), do: height
end
