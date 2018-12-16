defmodule Nodes do
    def read_node([num_children, num_metadata | rest_input]) do
        {children, next_input} = Enum.reduce(List.duplicate(true, num_children), {[], rest_input}, 
            fn _, {children, next_input} ->
                {child, next_input} = read_node(next_input)
                {[child] ++ children, next_input}
            end)
        metadata = Enum.take(next_input, num_metadata)
        node = {Enum.reverse(children), metadata}
        {node, Enum.drop(next_input, num_metadata)}
    end

    def sum_metadata({children, metadata}) do
        Enum.sum(metadata) + Enum.sum(Enum.map(children, &sum_metadata/1))
    end

    def value({[], metadata}) do
        Enum.sum(metadata)
    end

    def value({children, metadata}) do
        metadata
            |> Enum.filter(fn m -> m > 0 && m <= length(children) end)
            |> Enum.map(fn m -> value(Enum.fetch!(children, m - 1)) end)
            |> Enum.sum
    end
end

input = File.read!("input/8.input")
    |> String.split
    |> Enum.map(&String.to_integer/1)

{root, _} = Nodes.read_node(input)

IO.puts("Sum: #{Nodes.sum_metadata(root)}")
IO.puts("Value: #{Nodes.value(root)}")