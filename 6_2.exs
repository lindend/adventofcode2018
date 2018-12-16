defmodule Closest do
    def dist({p0x, p0y}, {p1x, p1y}) do
        abs(p0x - p1x) + abs(p0y - p1y)
    end

    def add({p0x, p0y}, {p1x, p1y}) do
        {p0x + p1x, p0y + p1y}
    end

    

end

raw_input = File.read!("6.input")
matcher = ~r/(\d+), (\d+)/

input = Regex.scan(matcher, raw_input)
    |> Enum.map(fn [_, xcoord, ycoord] -> {String.to_integer(xcoord, 10), String.to_integer(ycoord, 10)} end)

min_x = Enum.map(input, fn {x, _} -> x end) |> Enum.min
max_x = Enum.map(input, fn {x, _} -> x end) |> Enum.max

min_y = Enum.map(input, fn {_, y} -> y end) |> Enum.min
max_y = Enum.map(input, fn {_, y} -> y end) |> Enum.max

IO.puts("Min x #{min_x}, max x #{max_x}, min y #{min_y}, max y #{max_y}")

max_dists = for x <- min_x..max_x, y <- min_y..max_y do
    p = {x, y}
    dist = Enum.map(input, fn ip -> Closest.dist(p, ip) end)
    |> Enum.sum
    {p, dist}
end

within = Enum.filter(max_dists, fn {_, dist} -> dist < 10000 end)
IO.puts("Within length: #{length(within)}")

# input |>
#     Enum.map(fn p -> Closest.area(p, p, List.delete(input, p), %{p => true}, %{}) end) |>
#     # inspect |> IO.puts
#     Enum.filter(fn v -> v != :infinite end) |>
#     Enum.map(&Map.keys/1) |>
#     Enum.map(&length/1) |>
#     Enum.max |>
#     IO.puts
