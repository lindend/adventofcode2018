defmodule WaterScan do
    def parse(path) do
        x_range = ~r/x=(\d+)(?:\.\.(\d+))?/
        y_range = ~r/y=(\d+)(?:\.\.(\d+))?/
        File.stream!(path)
        |> Stream.map(&String.trim_trailing/1) 
        |> Enum.to_list
        |> Enum.reduce({%{}, 0}, fn line, {scan, max_y} ->
            xr = range(Regex.run(x_range, line))
            yr = range(Regex.run(y_range, line))
            (for x <- xr, y <- yr, do: {x, y})
            |> Enum.reduce({scan, max_y}, fn {x, y}, {scan, max_y} ->
                {Map.put({x, y}, true), max(y, max_y)}
            end)
        end)
    end

    def range([match, low, high]), do: low..high
    def range([match, low]), do: low..low

    def flow({_, max_y}, {_, current_y}, _) when current_y > max_y do
        0
    end

    def flow({scan, _} = input, {current_x, current_y} = pos, {last_x, _}) do
        current = Map.has_key?(scan, pos)
        below = Map.has_key?(scan, {current_x, pos + 1})
        cond do
            current -> 0
            below -> 1 + 
                case last_x do
                    current_x -> flow(input, {current_x - 1, current_y}, pos) + flow(input, {current_x + 1, current_y}, pos)
                    current_x - 1 -> flow(input, {current_x + 1, current_y}, pos)
                    current_x + 1 -> flow(input, {current_x - 1, current_y}, pos)
                end
            true -> 1 + flow(input, {current_x, current_y + 1})
        end
    end
end

scan = WaterScan.parse("input/17.input.test")