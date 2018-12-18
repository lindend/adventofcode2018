defmodule LumberArea do
    def parse(path) do
        File.stream!(path)
        |> Stream.map(&String.trim_trailing/1) 
        |> Enum.to_list
        |> Enum.map(&String.graphemes/1)
        |> Enum.map(fn l -> Enum.map(l, &convert_type/1) end)
        |> Enum.map(&List.to_tuple/1)
        |> List.to_tuple
    end

    def convert_type("."), do: :open
    def convert_type("|"), do: :trees
    def convert_type("#"), do: :lumberyard

    def next(grid) do
        for x <- 0..(tuple_size(grid)-1) do
            for y <- 0..(tuple_size(grid)-1) do
                get_next_cell(grid, x, y)
            end
        end
        |> Enum.map(&List.to_tuple/1)
        |> List.to_tuple
    end

    def get_next_cell(grid, x, y) do
        neighbours = (for x <- [-1, 0, 1], y <- [-1, 0, 1], do: {x, y})
            |> Enum.filter(fn p -> p != {0, 0} end)
            |> Enum.map(fn {dx, dy} -> cell_value(grid, x + dx, y + dy) end)
        cell = cell_value(grid, x, y)
        mutate(cell, neighbours)
    end

    def mutate(:open, neighbours) do
        num_trees = Enum.count(neighbours, fn n -> n == :trees end)
        cond do
            num_trees >= 3 -> :trees
            true -> :open
        end
    end

    def mutate(:trees, neighbours) do
        num_lumberyards = Enum.count(neighbours, fn n -> n == :lumberyard end)
        cond do
            num_lumberyards >= 3 -> :lumberyard
            true -> :trees
        end
    end

    def mutate(:lumberyard, neighbours) do
        num_trees = Enum.count(neighbours, fn n -> n == :trees end)
        num_lumberyards = Enum.count(neighbours, fn n -> n == :lumberyard end)

        cond do
            num_trees >= 1 && num_lumberyards >= 1 -> :lumberyard
            true -> :open
        end
    end

    def cell_value(grid, x, y) do
        size = tuple_size(grid)
        cond do
            x >= size || x < 0 -> nil
            y >= size || y < 0 -> nil
            true -> elem(grid, x) |> elem(y)
        end
    end

    def score(grid) do
        cells = Tuple.to_list(grid)
        |> Enum.flat_map(&Tuple.to_list/1)
        num_trees = Enum.count(cells, fn c -> c == :trees end)
        num_lumbers = Enum.count(cells, fn c -> c == :lumberyard end)
        num_trees * num_lumbers
    end
end

grid = LumberArea.parse("input/18.input")
{final, score} = Enum.reduce(1..10000, {grid, 0}, fn generation, {next, prev_score} -> 
    next_grid = LumberArea.next(next)
    score = LumberArea.score(next_grid)
    IO.puts("#{generation},#{score}")
    {next_grid, score}
end)