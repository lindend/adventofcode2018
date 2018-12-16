input = File.stream!("input/2.input")
|> Stream.map(&String.trim_trailing/1) 
|> Enum.to_list
|> Enum.map(&String.graphemes/1)

chunked = Enum.map(input, fn i -> 
    Enum.sort(i)
    |> Enum.chunk_by(fn i -> i end)
end)

threes = Enum.count(chunked, fn c -> Enum.any?(c, fn ci -> length(ci) == 3 end) end)
twos = Enum.count(chunked, fn c -> Enum.any?(c, fn ci -> length(ci) == 2 end) end)

IO.puts("Two: #{twos}. Three: #{threes}. Total: #{twos * threes}")

for b0 <- input, b1 <- input do
    {diffs, _} = Enum.reduce(b0, {0, b1}, fn c0, {diffs, [c1 | b1]} ->
        case c0 do
            ^c1 -> {diffs, b1}
            _ -> {diffs + 1, b1}  
        end
    end)
    if diffs == 1, do: IO.puts("Boxes: #{b0} and #{b1}")
end