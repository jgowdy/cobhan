package main

import (
	"encoding/base64"
	"math"
	"math/rand"
	"strings"
	"time"

	"godaddy.com/cobhan"
)

// Sample library exports for client testing
func init() {
	rand.Seed(time.Now().UnixNano())
}

//export sleepTest
func sleepTest(seconds int32) {
	time.Sleep(time.Duration(seconds) * time.Second)
}

//export addInt32
func addInt32(x int32, y int32) int32 {
	sum := x + y

	//Integers wrap in go, let's use MaxInt32 as a special case value to indicate overflow
	if x >= 0 && sum < y {
		return math.MaxInt32
	}

	//Integers wrap in go, let's use MinInt32 as a special case value to indicate underflow
	if x < 0 && sum > y {
		return math.MinInt32
	}

	return sum
}

//export addInt64
func addInt64(x int64, y int64) int64 {
	sum := x + y

	//Integers wrap in go, let's use MaxInt64 as a special case value to indicate overflow
	if x >= 0 && sum < y {
		return math.MaxInt64
	}

	//Integers wrap in go, let's use MinInt64 as a special case value to indicate underflow
	if x < 0 && sum > y {
		return math.MinInt64
	}

	return sum
}

//export addDouble
func addDouble(x float64, y float64) float64 {
	return x + y
}

const DefaultInputMaximum = 4096

//export toUpper
func toUpper(input cobhan.Buffer, output cobhan.Buffer) int32 {
	str, result := cobhan.InputBufferToString(input)
	if result != 0 {
		return result
	}

	str = strings.ToUpper(str)

	return cobhan.OutputStringToBuffer(str, output)
}

//export filterJson
func filterJson(input cobhan.Buffer, disallowedValue cobhan.Buffer, output cobhan.Buffer) int32 {
	jsonList, result := cobhan.InputBufferToJson(input)
	if result != 0 {
		return result
	}

	disallowedValueStr, result := cobhan.InputBufferToString(disallowedValue)
	if result != 0 {
		return result
	}

	for key := range jsonList {
		switch val := jsonList[key].(type) {
		case string:
			if strings.Contains(val, disallowedValueStr) {
				delete(jsonList, key)
			}
		}
	}

	return cobhan.OutputJsonToBuffer(jsonList, output)
}

//export base64Encode
func base64Encode(input cobhan.Buffer, output cobhan.Buffer) int32 {
	inputBytes, result := cobhan.InputBufferToBytes(input)
	if result != 0 {
		return result
	}

	outputLen := base64.StdEncoding.EncodedLen(len(inputBytes))
	outputBytes := make([]byte, outputLen)
	base64.StdEncoding.Encode(outputBytes, inputBytes)

	return cobhan.OutputBytesToBuffer(outputBytes, output)
}

//export generateRandom
func generateRandom(output cobhan.Buffer) int32 {
	randomSize := int32(rand.Intn(134217728))
	outputBytes := make([]byte, randomSize)
	_, err := rand.Read(outputBytes)
	if err != nil {
		return cobhan.ERR_COPY_FAILED
	}
	return cobhan.OutputBytesToBuffer(outputBytes, output)
}
