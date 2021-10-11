package main

import (
	"C"
	"encoding/base64"
	"math"
	"strings"
	"time"
)

// Sample library exports for client testing

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
func toUpper(input buffer, inputLen int32, output buffer, outputCap int32) int32 {
	str, result := InputString(input, inputLen, DefaultInputMaximum)
	if result != 0 {
		return result
	}

	str = strings.ToUpper(str)

	return OutputString(str, output, outputCap)
}

//export filterJson
func filterJson(input buffer, inputLen int32, disallowedValue buffer, disallowedValueLen int32, output buffer, outputCap int32) int32 {
	jsonList, result := InputJson(input, inputLen, DefaultInputMaximum)
	if result != 0 {
		return result
	}

	disallowedValueStr, result := InputString(disallowedValue, disallowedValueLen, DefaultInputMaximum)
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

	return OutputJson(jsonList, output, outputCap)
}

//export base64Encode
func base64Encode(input buffer, inputLen int32, output buffer, outputCap int32) int32 {
	inputBytes, result := InputBytes(input, inputLen, DefaultInputMaximum)
	if result != 0 {
		return result
	}

	outputLen := base64.StdEncoding.EncodedLen(int(inputLen))
	outputBytes := make([]byte, outputLen)
	base64.StdEncoding.Encode(outputBytes, inputBytes)

	return OutputBytes(outputBytes, output, outputCap)
}
