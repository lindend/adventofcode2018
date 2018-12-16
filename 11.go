package main

func powerLevel(x int, y int, serialNumber int) int {
	rackId := x + 10
	powerLevel := (rackId*y + serialNumber) * rackId
	powerLevel = (powerLevel / 100) % 10
	return powerLevel
}

func buildPowerGrid(serialNumber int) [300][300]int {
	powerGrid := [300][300]int{}

	for x := 0; x < 300; x++ {
		for y := 0; y < 300; y++ {
			powerGrid[y][x] = powerLevel(x+1, y+1, serialNumber)
		}
	}

	return powerGrid
}

func filterPowerGrid(powerGrid [300][300]int, size int) [][]int {
	filtered := make([][]int, 300)
	for r := range filtered {
		filtered[r] = make([]int, 300-size)
	}
	//x pass
	for y := 0; y < 300-size; y++ {
		for x := 0; x < 300-size; x++ {
			for s := 0; s < size; s++ {
				filtered[y][x] += powerGrid[y][x+s]
			}
		}
	}

	//y pass
	for y := 0; y < 300-size; y++ {
		for x := 0; x < 300-size; x++ {
			for s := 1; s < size; s++ {
				filtered[y][x] += filtered[y+s][x]
			}
		}
	}
	return filtered[0:(300 - size)]
}

func main() {
	serialNumber := 9798
	powerGrid := buildPowerGrid(serialNumber)

}
