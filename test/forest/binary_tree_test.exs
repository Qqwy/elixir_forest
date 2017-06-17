defmodule Forest.BinaryTreeTest do
  use ExUnit.Case
  doctest Forest.BinaryTree

  alias Forest.BinaryTree

  test "new/1, value/1" do
    assert BinaryTree.new(3) |> BinaryTree.value() == 3
  end

  test "size/1" do
    assert BinaryTree.new(1) |> BinaryTree.size == 1
    assert BinaryTree.new(1) |> BinaryTree.add_left(2) |> BinaryTree.size == 2
    res =
      BinaryTree.new(1)
      |> BinaryTree.add_left(2)
      |> BinaryTree.size
    assert res == 2
  end

  test "access behaviour" do
    tree = simple_tree()
    assert tree[[]] == 1
    assert tree[[:left]] == 2
    assert tree[[:right]] == 3
    assert tree[[:right, :left]] == 4
    assert tree[:left] == BinaryTree.new(2)
    assert tree[:right] == BinaryTree.new(3) |> BinaryTree.add_left(4)
  end

  test "get_and_update/3" do
    
  end

  def simple_tree do

    BinaryTree.new(1)
    |> BinaryTree.add_left(2)
    |> BinaryTree.add_subtree_right(BinaryTree.new(3) |> BinaryTree.add_left(4))
  end
end
