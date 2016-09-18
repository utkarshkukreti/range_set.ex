defmodule RangeSet do
  alias RangeSet.Node

  defstruct [:root]

  def new do
    %RangeSet{root: Node.new}
  end

  def contains?(%RangeSet{root: root}, term) do
     Node.contains?(root, term)
  end

  def put(%RangeSet{} = range_set, a, b) when a > b, do: put(range_set, b, a)
  def put(%RangeSet{root: root}, a, b) do
    %RangeSet{root: Node.put(root, a, b)}
  end
end
