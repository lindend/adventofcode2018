defmodule Power do
    def power_level({x, y}, serial_number) do
        rack_id = x + 10
        power_level = (rack_id * y + serial_number) * rack_id
        power_level = rem(div(power_level, 100), 10) - 5
        power_level
    end

    def power_grid(serial_number) do
        for y <- 1..300, x <- 1..300, do: {{x, y}, power_level({x, y}, serial_number)}
        |> Map.new  
    end

    def filter_one_dimension([], _) do
        0
    end

    def filter_one_dimension(_, 0) do
        0
    end

    def filter_one_dimension([power | next], size) do
        power + filter_one_dimension(next, size - 1)
    end

    def filtered_power_grid(power_grid, square_size) do
        x_pass = Enum.map()
    end

    def max_power(square_size, power_grid) do
        cells = for x <- 1..(300-square_size+1), y <- 1..(300-square_size+1), do: {x, y}
        Enum.reduce(cells, {-10, nil},
            fn {x, y}, {best_power, best_cell} ->
                total_power = (for cx <- x..(x + square_size - 1), cy <- y..(y + square_size - 1), do:
                        Power.power_level({cx, cy}, serial_number))
                    |> Enum.sum
                if total_power > best_power do
                    {total_power, {x, y}}
                else
                    {best_power, best_cell}
                end
            end)
    end
end

serial_number = 9798
import ExProf.Macro

profile do
power_grid = Power.power_grid(serial_number)

{best_size, {best_power, best_cell}} = 
Enum.map(1..10, fn square_size -> {square_size, Power.max_power(square_size, power_grid)} end)
|> Enum.max_by(fn {_, {best_power, _}} -> best_power end)
IO.puts("Best size: #{best_size}, best cell: #{inspect(best_cell)}, highest power: #{best_power}")

end