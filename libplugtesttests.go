package main

import (
	"fmt"
	"math"
	"strings"
	"unsafe"
)

/*
#include <stdlib.h> //For C.free
*/
import (
	"C"
)

// Test functions
const testStr = "Test String"

func toUpperTest() {
	// Simulate FFI Parameters
	input := C.CString(testStr) // This is a copy
	defer C.free(unsafe.Pointer(input))
	inputLen := (int32)(len(testStr))
	outputCap := (int32)(inputLen * 2) // Make it extra large to ensure we trim it properly
	bytes := make([]byte, outputCap)
	output := (*C.char)(unsafe.Pointer(&bytes))

	result := toUpper(input, inputLen, output, outputCap)
	if result < 0 {
		panic(fmt.Sprintf("toUpperTest failed: Result: %d", result))
	}

	outputStr := C.GoStringN(output, (C.int)(result))
	expectedStr := strings.ToUpper(testStr)
	if outputStr != expectedStr {
		panic(fmt.Sprintf("toUpperTest failed: Output: %s Expected: %s", outputStr, expectedStr))
	}

	inputStr := C.GoString(input)
	if inputStr != testStr {
		panic(fmt.Sprintf("toUpperTest failed: Input string was modified: Before: %s After: %s", testStr, inputStr))
	}

	fmt.Printf("toUpperTest success: %s became %s\n", testStr, outputStr)
}

func filterJsonTest() {
	inputJsonStr := `
    {
        "Name": "Anna",
        "Age": 18,
        "Movie": "Frozen 2"
    }`

	inputJson := C.CString(inputJsonStr)
	defer C.free(unsafe.Pointer(inputJson))
	inputJsonLen := int32(len(inputJsonStr))

	disallowedValueStr := "Frozen"
	disallowedValue := C.CString(disallowedValueStr)
	defer C.free(unsafe.Pointer(disallowedValue))
	disallowedValueLen := int32(len(disallowedValueStr))

	outputJsonCap := int32(inputJsonLen * 2)
	outputJsonBytes := make([]byte, outputJsonCap)
	outputJson := (*C.char)(unsafe.Pointer(&outputJsonBytes))

	result := filterJson(inputJson, inputJsonLen, disallowedValue, disallowedValueLen, outputJson, outputJsonCap)
	if result < 0 {
		panic("Failed to filter JSON")
	}

	outputStr := C.GoStringN(outputJson, C.int(result))

	fmt.Printf("Filtered JSON: %s\n", outputStr)

	if strings.Contains(outputStr, "Frozen") {
		panic("Failed to filter disallowed value out of JSON!")
	}
}

func testAllocation() {
	buffer := allocateTestBuffer(1024)
	defer freeTestBuffer(buffer)
}

func addInt32Test() {
	result := addInt32(math.MaxInt32, 1)
	if result != math.MaxInt32 {
		panic(fmt.Sprintf("Unexpected result %d for overflow 1", result))
	}

	result = addInt32(math.MaxInt32, math.MaxInt32)
	if result != math.MaxInt32 {
		panic(fmt.Sprintf("Unexpected result %d for overflow 2", result))
	}

	result = addInt32(math.MinInt32, -1)
	if result != math.MinInt32 {
		panic(fmt.Sprintf("Unexpected result %d for underflow 1", result))
	}

	result = addInt32(math.MinInt32, math.MinInt32)
	if result != math.MinInt32 {
		panic(fmt.Sprintf("Unexpected result %d for underflow 2", result))
	}
}

func addInt64Test() {
	result := addInt64(math.MaxInt64, 1)
	if result != math.MaxInt64 {
		panic(fmt.Sprintf("Unexpected result %d for overflow 1", result))
	}

	result = addInt64(math.MaxInt64, math.MaxInt64)
	if result != math.MaxInt64 {
		panic(fmt.Sprintf("Unexpected result %d for overflow 2", result))
	}

	result = addInt64(math.MinInt64, -1)
	if result != math.MinInt64 {
		panic(fmt.Sprintf("Unexpected result %d for underflow 1", result))
	}

	result = addInt64(math.MinInt64, math.MinInt64)
	if result != math.MinInt64 {
		panic(fmt.Sprintf("Unexpected result %d for underflow 2", result))
	}
}

func addDoubleTest() {
	result := addDouble(math.MaxFloat64, 1)

	if result != math.MaxFloat64 {
		panic(fmt.Sprintf("Unexpected result %f for overflow 1", result))
	}

	result = addDouble(math.MaxFloat64, math.MaxFloat64)
	if !math.IsInf(result, 1) {
		panic(fmt.Sprintf("Unexpected result %f for overflow 2", result))
	}

	result = addDouble(-math.MaxFloat64, -1)
	if result != -math.MaxFloat64 {
		panic(fmt.Sprintf("Unexpected result %f for underflow 1", result))
	}

	result = addDouble(-math.MaxFloat64, -math.MaxFloat64)
	if !math.IsInf(result, -1) {
		panic(fmt.Sprintf("Unexpected result %f for underflow 2", result))
	}
}
