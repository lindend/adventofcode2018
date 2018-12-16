defmodule Closest do
    def dist({p0x, p0y}, {p1x, p1y}) do
        abs(p0x - p1x) + abs(p0y - p1y)
    end

    def add({p0x, p0y}, {p1x, p1y}) do
        {p0x + p1x, p0y + p1y}
    end

    def area(p, currentCell, otherPoints, visited, previous_dists) do
        distance = dist(p, currentCell)
        dists = Enum.map(otherPoints, fn op -> {op, dist(currentCell, op)} end) |> Map.new
        currentClosest = Enum.map(otherPoints, fn op -> dist(currentCell, op) end) |> Enum.min
        cond do
            visited == :infinite ->
                :infinite
            distance >= currentClosest ->
                visited
            previous_dists != %{} && Enum.all?(previous_dists, fn {point, dist} -> Map.get(dists, point) > dist end) ->
                :infinite
            true ->
                visited = Map.put(visited, currentCell, true)
                Enum.reduce([{1,0},{0,1},{-1,0},{0,-1}], visited, fn pOffset, vs ->
                    newPoint = add(currentCell, pOffset)
                    cond do
                        vs == :infinite -> :infinite
                        Map.has_key?(vs, newPoint) ->
                            vs
                        true -> area(p, newPoint, otherPoints, vs, dists)
                    end
                end)
        end
    end

end

raw_input = File.read!("6.input")
matcher = ~r/(\d+), (\d+)/

input = Regex.scan(matcher, raw_input)
    |> Enum.map(fn [_, xcoord, ycoord] -> {String.to_integer(xcoord, 10), String.to_integer(ycoord, 10)} end)


input |>
    Enum.map(fn p -> Closest.area(p, p, List.delete(input, p), %{p => true}, %{}) end) |>
    # inspect |> IO.puts
    Enum.filter(fn v -> v != :infinite end) |>
    Enum.map(&Map.keys/1) |>
    Enum.map(&length/1) |>
    Enum.max |>
    IO.puts
