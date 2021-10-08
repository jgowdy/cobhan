package main

import (
	"fmt"
	"math"
	"strings"

	"godaddy.com/cobhan"
)

// Test functions
const testStr = "Test String"

func toUpperTest() {
	// Simulate FFI Parameters
	inputLen := (int32)(len(testStr))
    input := cobhan.TestAllocateStringBuffer(testStr)
	defer cobhan.TestFreeBuffer(input)

	outputCap := (int32)(inputLen * 2) // Make it extra large to ensure we trim it properly
    output := cobhan.TestAllocateBuffer(outputCap)
    defer cobhan.TestFreeBuffer(output)

	result := toUpper(input, inputLen, output, outputCap)
	if result < 0 {
		panic(fmt.Sprintf("toUpperTest failed: Result: %d", result))
	}

    expectedStr := strings.ToUpper(testStr)
    cobhan.TestStringAssertion("toUpperTest output mismatch", output, result, expectedStr)

    // Assert that the input buffer wasn't modified
    cobhan.TestStringAssertion("toUpperTest input buffer modified", input, inputLen, testStr)

    fmt.Println("toUpperTest passed")
}

func filterJsonTest() {
	inputJsonStr := `
    {
        "Name": "Anna",
        "Age": 18,
        "Movie": "Frozen 2"
    }`

    inputJsonLen := int32(len(inputJsonStr))
    inputJson := cobhan.TestAllocateStringBuffer(inputJsonStr)
    defer cobhan.TestFreeBuffer(inputJson)

	disallowedValueStr := "Frozen"
	disallowedValueLen := int32(len(disallowedValueStr))
    disallowedValue := cobhan.TestAllocateStringBuffer(disallowedValueStr)
    defer cobhan.TestFreeBuffer(disallowedValue)


	outputJsonCap := int32(inputJsonLen * 2)
    outputJson := cobhan.TestAllocateBuffer(outputJsonCap)
    defer cobhan.TestFreeBuffer(outputJson)

	result := filterJson(inputJson, inputJsonLen, disallowedValue, disallowedValueLen, outputJson, outputJsonCap)
	if result < 0 {
		panic(fmt.Sprintf("filterJson failed: Result: %d", result))
	}

    cobhan.TestStringNotAssertion("disallowed value filtered", outputJson, result, disallowedValueStr)
    fmt.Println("filterJsonTest passed")
}

func allocationTest() {
	buffer := cobhan.TestAllocateBuffer(1024)
	defer cobhan.TestFreeBuffer(buffer)
    fmt.Println("allocationTest passed")
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

    fmt.Println("addInt32Test passed")
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

    fmt.Println("addInt64Test passed")
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

    fmt.Println("addDoubleTest passed")
}
