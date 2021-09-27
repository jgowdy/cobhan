package main

import (
	"C"
	"encoding/json"
	"strings"
	"time"
)

// String passing requirements
// * All strings are passed as pointers + signed int32 lengths (length delimited)
// * Callers may append null to strings but we do not
// * Callers provide the output buffer and capacity
// * Callers can re-use the input buffer as the output buffer (memmove semantics)
// * Insufficient capacity in output buffer causes functions to fail by returning less than zero



// Sample library exports for client testing

//export sleepTest
func sleepTest(seconds int32) {
	time.Sleep(time.Duration(seconds) * time.Second)
}

//export addInt32
func addInt32(x int32, y int32) int32 {
	return x + y
}

//export addDouble
func addDouble(x float64, y float64) float64 {
	return x + y
}

//export addInt64
func addInt64(x int64, y int64) int64 {
	return x + y
}

//export toUpper
func toUpper(input *C.char, inputLen int32, output *C.char, outputCap int32) int32 {
	str, err := GoString(input, inputLen)
	if err != nil {
		return ERR_NULL_PTR
	}

	str = strings.ToUpper(str)

	return CopyStringToCStr(str, output, outputCap)
}

//export filterJson
func filterJson(input *C.char, inputLen int32, disallowedValue *C.char, disallowedValueLen int32, output *C.char, outputCap int32) int32 {
	jsonList, err := LoadJson(input, inputLen)
	if err != nil {
		return ERR_JSON_FAIL
	}

	disallowedValueStr, err := GoString(disallowedValue, disallowedValueLen)
	if err != nil {
		return ERR_NULL_PTR
	}

	for key := range jsonList {
		switch val := jsonList[key].(type) {
		case string:
			if strings.Contains(val, disallowedValueStr) {
				delete(jsonList, key)
			}
		}
	}

	outputBytes, err := json.Marshal(jsonList)
	if err != nil {
		return ERR_JSON_FAIL
	}
	return CopyBytesToCStr(outputBytes, output, outputCap)
}
