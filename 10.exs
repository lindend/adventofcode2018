defmodule StarMessage do
    def simulate_point({x, y, vx, vy}, time), do: {x + vx * time, y + vy * time}

    def simulate(input, time) do
        input 
            |> Enum.map(fn i -> simulate_point(i, time) end)
    end
    def score(input) do
        xs = Enum.map(input, fn {x, _} -> x end)
        -(Enum.max(xs) - Enum.min(xs))
    end
    def print_message(input) do
        xs = Enum.map(input, fn {x, _} -> x end)
        ys = Enum.map(input, fn {_, y} -> y end)
        max_x = Enum.max(xs)
        max_y = Enum.max(ys)
        min_x = Enum.min(xs)
        min_y = Enum.min(ys)

        input_map = Map.new(input, fn i -> {i, true} end)

        for y <- min_y..max_y do
            line = Enum.map(min_x..max_x, fn x -> 
                cond do
                    Map.has_key?(input_map, {x, y}) -> "#"
                    true -> "."
                end
            end)
            |> Enum.join("")

            IO.puts(line)
        end
    end

    def decrypt(input, time \\ 1, best \\ 0) do
        input_at_time = simulate(input, time)
        score = score(input_at_time)
        cond do
            score > best ->
                IO.puts("New best! Score: #{score}, time: #{time}")
                # print_message(input_at_time)
                decrypt(input, time + 1, score)
            true ->
                decrypt(input, time + 1, best)
        end
    end
end

raw_input = File.read!("input/10.input")
matcher = ~r/position=<\s*(-?\d+),\s*(-?\d+)> velocity=<\s*(-?\d+),\s*(-?\d+)>/

input = Regex.scan(matcher, raw_input)
    |> Enum.map(fn [_, x, y, vx, vy] -> {String.to_integer(x, 10), String.to_integer(y, 10),
                                        String.to_integer(vx, 10), String.to_integer(vy, 10)} end)

StarMessage.decrypt(input, 1, -100)


