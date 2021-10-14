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
func toUpper(input cobhan.Buffer, inputLen int32, output cobhan.Buffer, outputCap int32) int32 {
	str, result := cobhan.InputString(input, inputLen, DefaultInputMaximum)
	if result != 0 {
		return result
	}

	str = strings.ToUpper(str)

	return cobhan.OutputString(str, output, outputCap)
}

//export filterJson
func filterJson(input cobhan.Buffer, inputLen int32, disallowedValue cobhan.Buffer, disallowedValueLen int32, output cobhan.Buffer, outputCap int32) int32 {
	jsonList, result := cobhan.InputJson(input, inputLen, DefaultInputMaximum)
	if result != 0 {
		return result
	}

	disallowedValueStr, result := cobhan.InputString(disallowedValue, disallowedValueLen, DefaultInputMaximum)
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

	return cobhan.OutputJson(jsonList, output, outputCap)
}

//export base64Encode
func base64Encode(input cobhan.Buffer, inputLen int32, output cobhan.Buffer, outputCap int32) int32 {
	inputBytes, result := cobhan.InputBytes(input, inputLen, DefaultInputMaximum)
	if result != 0 {
		return result
	}

	outputLen := base64.StdEncoding.EncodedLen(int(inputLen))
	outputBytes := make([]byte, outputLen)
	base64.StdEncoding.Encode(outputBytes, inputBytes)

	return cobhan.OutputBytes(outputBytes, output, outputCap)
}

//export generateRandom
func generateRandom(output cobhan.Buffer, outputCap int32) int32 {
    int32 randomSize = rand.Intn(134217728)
    if outputCap < randomSize {
        return ERR_OUTPUT_BUFFER_TOO_SMALL;
    }
    outputBytes := make([]byte, randomSize)
    n, err := rand.Read(outputBytes)
    if err != nil {
        return ERR_COPY_FAILED
    }
    return cobhan.OutputBytes(outputBytes, output, outputCap)
}

//export generateRandomTmp
func generateRandomTmp(output cobhan.Buffer, outputCap int32) int32 {
    int32 randomSize = rand.Intn(134217728)
    if outputCap < randomSize {
        return ERR_OUTPUT_BUFFER_TOO_SMALL;
    }
    outputBytes := make([]byte, randomSize)
    n, err := rand.Read(outputBytes)
    if err != nil {
        return ERR_COPY_FAILED
    }
    return cobhan.OutputBytesTmp(outputBytes, output, outputCap)
}
