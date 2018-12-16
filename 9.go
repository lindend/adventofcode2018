package main

import (
	"container/ring"
	"fmt"
)

func main() {
	circle := ring.New(1)
	circle.Value = 0
	score := make(map[int]int)

	numPlayers := 465
	lastMarble := 7149800

	for i := 1; i <= lastMarble; i++ {
		if i%23 == 0 {
			circle = circle.Move(-6)
			toRemove := circle.Move(-2)
			score[i%numPlayers] += circle.Prev().Value.(int) + i
			toRemove.Unlink(1)
		} else {
			newElement := ring.New(1)
			newElement.Value = i
			circle = circle.Next().Link(newElement).Prev()
		}
	}

	maxScore := 0

	for _, v := range score {
		if v > maxScore {
			maxScore = v
		}
	}

	fmt.Printf("Max: %v\n", maxScore)
}
