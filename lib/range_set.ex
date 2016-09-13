defmodule RangeSet do
  defstruct [:root]

  def new do
    %RangeSet{root: nil}
  end
end
