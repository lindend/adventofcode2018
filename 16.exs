defmodule Bytecode do
    use Bitwise
    def gt(va, vb, c, registers) do
        vc = cond do
            va > vb -> 1
            true -> 0
        end
        put_elem(registers, c, vc)
    end

    def eq(va, vb, c, registers) do
        vc = cond do
            va == vb -> 1
            true -> 0
        end
        put_elem(registers, c, vc)
    end

    def exec({:addr, a, b, c}, registers) do
        va = elem(registers, a)
        vb = elem(registers, b)
        put_elem(registers, c, va + vb)
    end

    def exec({:addi, a, vb, c}, registers) do
        va = elem(registers, a)
        put_elem(registers, c, va + vb)
    end

    def exec({:mulr, a, b, c}, registers) do
        va = elem(registers, a)
        vb = elem(registers, b)
        put_elem(registers, c, va * vb)
    end

    def exec({:muli, a, vb, c}, registers) do
        va = elem(registers, a)
        put_elem(registers, c, va * vb)
    end

    def exec({:banr, a, b, c}, registers) do
        va = elem(registers, a)
        vb = elem(registers, b)
        put_elem(registers, c, band(va, vb))
    end
    def exec({:bani, a, vb, c}, registers) do
        va = elem(registers, a)
        put_elem(registers, c, band(va, vb))
    end

    def exec({:borr, a, b, c}, registers) do
        va = elem(registers, a)
        vb = elem(registers, b)
        put_elem(registers, c, bor(va, vb))
    end
    def exec({:bori, a, vb, c}, registers) do
        va = elem(registers, a)
        put_elem(registers, c, bor(va, vb))
    end

    def exec({:setr, a, _, c}, registers) do
        va = elem(registers, a)
        put_elem(registers, c, va)
    end
    def exec({:seti, va, _, c}, registers) do
        put_elem(registers, c, va)
    end

    def exec({:gtir, va, b, c}, registers) do
        vb = elem(registers, b)
        gt(va, vb, c, registers)
    end

    def exec({:gtri, a, vb, c}, registers) do
        va = elem(registers, a)
        gt(va, vb, c, registers)
    end

    def exec({:gtrr, a, b, c}, registers) do
        va = elem(registers, a)
        vb = elem(registers, b)
        gt(va, vb, c, registers)
    end

    def exec({:eqir, va, b, c}, registers) do
        vb = elem(registers, b)
        eq(va, vb, c, registers)
    end

    def exec({:eqri, a, vb, c}, registers) do
        va = elem(registers, a)
        eq(va, vb, c, registers)
    end

    def exec({:eqrr, a, b, c}, registers) do
        va = elem(registers, a)
        vb = elem(registers, b)
        eq(va, vb, c, registers)
    end
end

instructions = [
    :addi, 
    :addr,
    :muli,
    :mulr,
    :bani,
    :banr,
    :bori,
    :borr,
    :seti,
    :setr,
    :gtir,
    :gtri,
    :gtrr,
    :eqir,
    :eqri,
    :eqrr
]

matcher = ~r/Before: \[(\d+), (\d+), (\d+), (\d+)\]
(\d+) (\d+) (\d+) (\d)
After:\s+\[(\d+), (\d+), (\d+), (\d+)\]/

raw_input = File.read!("input/16.input")
input = Regex.scan(matcher, raw_input)
|> Enum.map(fn [_ | matches] -> Enum.map(matches, fn m -> String.to_integer(m, 10) end) end)
|> Enum.map(fn [br0, br1, br2, br3, op, a, b, c, ar0, ar1, ar2, ar3] ->
        {{br0, br1, br2, br3}, {op, a, b, c}, {ar0, ar1, ar2, ar3}}
    end)


candidates = Enum.map(input, fn {before, operation, aftr} ->
    opcode = elem(operation, 0)
    {opcode, Enum.map(instructions, fn i -> 
        {i, Bytecode.exec(put_elem(operation, 0, i), before)}
    end)
    |> Enum.filter(fn {_, result} -> result == aftr end)
    |> Enum.map(&(elem(&1, 0)))}
end)
three_or_more = Enum.filter(candidates, fn {_, c} -> length(c) >= 3 end) |> length

IO.puts("Three or more #{three_or_more} of #{length(input)}")

candidate_map = Enum.reduce(candidates, %{}, fn {opcode, cs}, cmap -> 
    ms = MapSet.new(cs)
    Map.update(cmap, opcode, ms, fn current -> MapSet.intersection(current, ms) end)
end)
{opcode_map, _} = Enum.reduce(1..length(instructions), {%{}, Map.to_list(candidate_map)}, fn _, {opcode_map, candidate_list} ->
    {opcode, iset} = Enum.find(candidate_list, fn {_, cs} -> MapSet.size(cs) == 1 end)
    [instruction] = MapSet.to_list(iset)
    candidate_list = Enum.map(candidate_list, fn {oc, cs} -> {oc, MapSet.delete(cs, instruction)} end)
    {Map.put(opcode_map, opcode, instruction), candidate_list}
end)

IO.puts("Opcodes: #{inspect(opcode_map)}")

part2_matcher = ~r/(\d+) (\d+) (\d+) (\d)/
raw_input2 = File.read!("input/16_2.input")
program = Regex.scan(part2_matcher, raw_input2)
|> Enum.map(fn [_ | matches] -> Enum.map(matches, fn m -> String.to_integer(m, 10) end) end)
|> Enum.map(fn [op, a, b, c] -> {Map.get(opcode_map, op), a, b, c} end)

result = Enum.reduce(program, {0, 0, 0, 0}, fn operation, registers -> Bytecode.exec(operation, registers) end)
IO.puts("Result of test program: #{inspect(result)}")

# IO.puts("One candidate: #{one}")