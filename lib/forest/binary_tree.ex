defmodule Forest.BinaryTree do
  @moduledoc """
  A simple Binary Tree.

  Does not follow any special rules for inserting/extracting nodes.
  Many other types of data structures are built on top of this.
  """


  @type t(val) :: %{left: nil | t(val), right: nil | t(val), value: val, size: pos_integer, height: pos_integer}
  @type t :: t(any)
  @typep val :: any

  @enforce_keys [:value]
  defstruct [:value, left: nil, right: nil, size: 1, height: 1]

  @spec new(val :: any) :: t(val)
  def new(value) do
    %__MODULE__{value: value, size: 1, height: 1}
  end

  @spec value(t(val)) :: val
  def value(%__MODULE__{value: value}) do
    value
  end

  @spec leaf?(t(any)) :: boolean
  def leaf?(tree)
  def leaf?(%__MODULE__{left: nil, right: nil}), do: true
  def leaf?(%__MODULE__{}), do: false

  @spec size(t(any)) :: pos_integer
  def size(tree = %__MODULE__{}) do
    tree.size
  end

  @spec height(t(any)) :: pos_integer
  def height(tree = %__MODULE__{}) do
    tree.height
  end

  @spec left(t(val)) :: {:ok, val} | {:error, :leaf_node}
  def left(%__MODULE__{left: nil}), do: {:error, :leaf_node}
  def left(%__MODULE__{left: left}), do: {:ok, left}

  @spec left!(t(val)) :: t(val)
  def left!(tree = %__MODULE__{}) do
    {:ok, left} = left(tree)
    left
  end

  @spec right(t(val)) :: {:ok, val} | {:error, :leaf_node}
  def right(%__MODULE__{right: nil}), do: {:error, :leaf_node}
  def right(%__MODULE__{right: right}), do: {:ok, right}

  @spec right!(t(val)) :: t(val)
  def right!(tree = %__MODULE__{}) do
    {:ok, right} = right(tree)
    right
  end

  @spec add_left(t(val), val) :: t(val)
  def add_left(tree = %__MODULE__{left: left, right: right}, value) do
    tree
    |> Map.put(:left, new(value))
    |> Map.put(:size, if(left, do: tree.size, else: tree.size + 1))
    |> Map.put(:height, max(left[:height] || 0, right[:height] || 0) + 1)
  end

  @spec add_right(t(val), val) :: t(val)
  def add_right(tree = %__MODULE__{left: left, right: right}, value) do
    tree
    |> Map.put(:right, new(value))
    |> Map.put(:size, if(right, do: tree.size, else: tree.size + 1))
    |> Map.put(:height, max(left[:height] || 0, right[:height] || 0) + 1)
  end

  @spec add_subtree_left(t(val), t(val)) :: t(val)
  def add_subtree_left(tree = %__MODULE__{right: right}, subtree = %__MODULE__{}) do
    size =
      case tree.left do
        nil -> tree.size
        left -> tree.size - left.size
      end
    %__MODULE__{tree | left: subtree, size: size + subtree.size}
    |> Map.put(:height, max(subtree[:height] || 0, right[:height] || 0) + 1)
  end

  @spec add_subtree_right(t(val), t(val)) :: t(val)
  def add_subtree_right(tree = %__MODULE__{left: left}, subtree = %__MODULE__{}) do
    size =
      case tree.right do
        nil -> tree.size
        right -> tree.size - right.size
      end
    %__MODULE__{tree | right: subtree, size: size + subtree.size}
    |> Map.put(:height, max(left[:height] || 0, subtree[:height] || 0) + 1)
  end

  @spec pre_order_map(t(val), (a -> b)) :: t(b) when a: val, b: any
  def pre_order_map(%__MODULE__{left: nil, right: nil, value: value}, function) do
    new(function.(value))
  end

  def pre_order_map(%__MODULE__{left: left, right: right, value: value}, function) do
    %__MODULE__{left: pre_order_map(left, function), value: function.(value), right: pre_order_map(right, function)}
  end

  @spec in_order_map(t(val), (a -> b)) :: t(b) when a: val, b: any
  def in_order_map(%__MODULE__{left: nil, right: nil, value: value}, function) do
    new(function.(value))
  end

  def in_order_map(%__MODULE__{left: left, right: right, value: value}, function) do
    %__MODULE__{value: function.(value), left: pre_order_map(left, function), right: pre_order_map(right, function)}
  end

  @spec post_order_map(t(val), (a -> b)) :: t(b) when a: val, b: any
  def post_order_map(%__MODULE__{left: nil, right: nil, value: value}, function) do
    new(function.(value))
  end

  def post_order_map(%__MODULE__{left: left, right: right, value: value}, function) do
    %__MODULE__{right: pre_order_map(right, function), value: function.(value, function), left: pre_order_map(left, function)}
  end

  @doc """
  Access the left subtree by using `:left`
  the right subtree by using `:right`,
  the current value by using `[]` and the value
  of a node further down using something like: `[:left, :right, :right]`
  """
  @spec fetch(t(val), :left | :right) :: {:ok, val} | :error
  def fetch(%__MODULE__{left: nil}, :left), do: :error
  def fetch(%__MODULE__{right: nil}, :right), do: :error
  def fetch(%__MODULE__{left: left}, :left), do: {:ok, left}
  def fetch(%__MODULE__{right: right}, :right), do: {:ok, right}
  def fetch(%__MODULE__{value: value}, []), do: {:ok, value}
  def fetch(%__MODULE__{left: nil}, [:left | _]), do: :error
  def fetch(%__MODULE__{right: nil}, [:right | _]), do: :error
  def fetch(%__MODULE__{left: left}, [:left | rest]), do: fetch(left, rest)
  def fetch(%__MODULE__{right: right}, [:right | rest]), do: fetch(right, rest)
  def fetch(%__MODULE__{}, _), do: :error

  def get(tree = %__MODULE__{}, key, default \\ nil) do
    case fetch(tree, key) do
      {:ok, value} -> value
      :error       -> default
    end
  end

  def get_and_update(tree = %__MODULE__{value: value}, [], function) do
    # value = get(tree, key)
    case function.(value) do
      {get, updated_value} ->
        {get, %__MODULE__{tree | value: updated_value}}
      :pop ->
        {value, nil}
      other ->
        raise "the given function must return a two-element tuple or :pop, got: #{inspect(other)}"
    end
  end
  def get_and_update(tree = %__MODULE__{left: left}, _key = [:left | rest], function) do
    %__MODULE__{tree | left: get_and_update(left, rest, function)}
  end
  def get_and_update(tree = %__MODULE__{right: right}, _key = [:right | rest], function) do
    %__MODULE__{tree | right: get_and_update(right, rest, function)}
  end
  def get_and_update(tree = %__MODULE__{right: right}, _key = :right, function) do
    case function.(right) do
      {get, updated_value} ->
        {get, %__MODULE__{tree | right: updated_value}}
      :pop ->
        {right, nil}
      other ->
        raise "the given function must return a two-element tuple or :pop, got: #{inspect(other)}"
    end
  end
  def get_and_update(tree = %__MODULE__{left: left}, _key = :left, function) do
    case function.(left) do
      {get, updated_value} ->
        {get, %__MODULE__{tree | left: updated_value}}
      :pop ->
        {left, nil}
      other ->
        raise "the given function must return a two-element tuple or :pop, got: #{inspect(other)}"
    end
  end

  def pop(tree, key, default \\ nil)
  def pop(tree, :left, default) do
    {tree.left || default, %__MODULE__{tree | left: nil}}
  end
  def pop(tree, :right, default) do
    {tree.right || default, %__MODULE__{tree | right: nil}}
  end
  def pop(tree, [], default) do
    {tree || default, nil}
  end
  def pop(tree, [:left | rest], default) do
    case tree.left do
      nil ->
        {default, tree}
      left ->
        {val, updated_left} = pop(left, rest)
        {val, %__MODULE__{tree | left: updated_left}}
    end
  end
  def pop(tree, [:right | rest], default) do
    case tree.right do
      nil ->
        {default, tree}
      right ->
        {val, updated_right} = pop(right, rest)
        {val, %__MODULE__{tree | right: updated_right}}
    end
  end
end
