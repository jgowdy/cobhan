package main

import (
	"C"
	"encoding/base64"
	"math"
	"strings"
	"time"
)

//Types:
/*
   Supported scalar types:
       int32 - 32 bit signed integer
       int64 - 64 bit signed integer
       float64 - double precision 64 bit IEEE 754 floating point

   Supported buffer types:
       string - utf-8 encoded length delimited string
       JSON - utf-8 encoded length delimited string containing valid JSON
       []byte - 8 bit raw binary buffer

   Buffer passing requirements:
       * All buffers are passed as pointers + signed int32 lengths (length delimited)
       * Callers may optionally append null to strings or JSON but must not include the null in the length
       * No guarantee of null termination on returned output buffers
       * Callers provide the output buffer allocation and capacity
       * Callers can re-use the input buffer as the output buffer (memmove/copy semantics)
       * Insufficient capacity in output buffer causes functions to fail by returning less than zero

   Output buffer sizing:
       * Callers may know the appropriate output buffer size
           * If it is a fixed / constant documented size
           * If it matches the input buffer size
           * If it can be computed from the input buffer size in an documented fashion (e.g. Base64)
           * If the library provides a method that returns the output buffer size for a provided input buffer size

       * When output buffer size cannot be predicted easily callers may utilize a buffer pool with a tuned
           buffer size that covers most rational cases

      * When functions return insufficient buffer errors (should be rare) caller can allocate increasing buffer
           sizes up to a maximum size, retrying until the operation is successful

   Return values:
       * Functions that return scalar values can return the value directly
           * Functions *can* use special case and return maximum positive or maximum negative or zero values to
               represent error or overflow conditions
           * Functions *can* allow scalar values to wrap, which is the default behavior in Go
           * Functions should document their overflow / underflow behavior

       * Functions that return buffer values should return an int32 containing the populated output buffer length or
           an error code if the value is less than zero

*/

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
