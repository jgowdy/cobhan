package main

import (
	"C"
	"encoding/base64"
	"math"
	"math/rand"
	"strings"
	"time"
	"unsafe"

	"godaddy.com/cobhan"
)

func main() {
}

// Sample library exports for client testing
func init() {
	//rand.Seed(time.Now().UnixNano())
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
		DebugOutput("Returning saturated MaxInt32 for addInt32")
		return math.MaxInt32
	}

	//Integers wrap in go, let's use MinInt32 as a special case value to indicate underflow
	if x < 0 && sum > y {
		DebugOutput("Returning saturated MinInt32 for addInt32")
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
func toUpper(input unsafe.Pointer, output unsafe.Pointer) int32 {
	str, result := cobhan.BufferToString(input)
	if result != 0 {
		return result
	}

	str = strings.ToUpper(str)

	return cobhan.StringToBuffer(str, output)
}

//export filterJson
func filterJson(input unsafe.Pointer, disallowedValue unsafe.Pointer, output unsafe.Pointer) int32 {
	jsonList, result := cobhan.BufferToJson(input)
	if result != 0 {
		return result
	}

	disallowedVal, result := cobhan.BufferToString(disallowedValue)
	if result != 0 {
		return result
	}

	for key := range jsonList {
		switch val := jsonList[key].(type) {
		case string:
			if strings.Contains(val, disallowedVal) {
				delete(jsonList, key)
			}
		}
	}

	return cobhan.JsonToBuffer(jsonList, output)
}

//export base64Encode
func base64Encode(input unsafe.Pointer, output unsafe.Pointer) int32 {
	inputBytes, result := cobhan.BufferToBytes(input)
	if result != 0 {
		return result
	}

	outputLen := base64.StdEncoding.EncodedLen(len(inputBytes))
	outputBytes := make([]byte, outputLen)
	base64.StdEncoding.Encode(outputBytes, inputBytes)

	return cobhan.BytesToBuffer(outputBytes, output)
}

//export generateRandom
func generateRandom(output unsafe.Pointer) int32 {
	randomSize := int32(rand.Intn(134217728))
	outputBytes := make([]byte, randomSize)
	_, err := rand.Read(outputBytes)
	if err != nil {
		return cobhan.ERR_COPY_FAILED
	}
	return cobhan.BytesToBuffer(outputBytes, output)
}
