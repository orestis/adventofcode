  defmodule Circle do
    # how does a circle looks like?
    # it is a double-linked list
    # that the end points back to the front
    defmodule Node do
      defstruct value: nil, next: nil, prev: nil

      def fetch(n, k) do
        n[k]
      end

      defimpl String.Chars, for: Node do
        def to_string(n) do
          "Node #{n.value}, next: #{n.next}, prev: #{n.prev}"
        end
      end

    end

    def new() do
      :ets.new(:circle, [])
    end

    def from_values(circle, [h|t]) do
      insert(circle, %Node{value: h})
      from_values(circle, t, h, h)
    end

    def from_values(circle, [], prev, first) do
      update(circle, first, [prev: prev])
      update(circle, prev, [next: first])
      {circle, first}
    end

    def from_values(circle, [h|t], prev, first) do
      update(circle, prev, [next: h])
      insert(circle, %Node{value: h, prev: prev})
      from_values(circle, t, h, first)
    end


    def delete(circle) do
      :ets.delete(circle)
    end

    def delete(circle, node) do
      next = next(circle, node)
      prev = prev(circle, node)
      update(circle, prev, [next: next])
      update(circle, next, [prev: prev])
      :ets.delete(circle, node)
    end

    def next(circle, node) do
      node = get_node(circle, node)
      get(circle, node.next)
    end

    def prev(circle, node) do
      node = get_node(circle, node)
      get(circle, node.prev)
    end

    def get(circle, n) do
      get_node(circle, n).value
    end

    defp get_node(circle, value) do
      :ets.lookup(circle, value) |> Enum.at(0) |> elem(1)
    end

    def insert(circle, node) do
      :ets.insert(circle, {node.value, node})
      circle
    end

    def skip(circle, node, 0), do: node
    def skip(circle, node, left) do
      node = next(circle, node)
      skip(circle, node, left-1)
    end


    defp update(circle, curr, params) do
      c = get_node(circle, curr)
      new_node = struct(c, params)
      :ets.insert(circle, {new_node.value, new_node})
    end

  end
