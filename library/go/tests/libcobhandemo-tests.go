package main

import (
    "fmt"
    "math"
    "strings"

    "godaddy.com/cobhan"
)

// Test functions
const testStr = "TestStringTestStringTestStringTestStringTestStringTestStringTestStringTestStringTestStringTestString"

func toUpperTest() {
    // Simulate FFI Parameters
    input := cobhan.TestAllocateStringBuffer(testStr)
    defer cobhan.TestFreeBuffer(input)

    output := cobhan.TestAllocateBuffer(len(testStr) * 2) // Make it extra large to ensure we trim it properly
    defer cobhan.TestFreeBuffer(output)

    result := toUpper(input, output)
    if result < cobhan.ERR_NONE {
        panic(fmt.Sprintf("toUpperTest failed: Result: %d", result))
    }

    expectedStr := strings.ToUpper(testStr)
    cobhan.TestStringAssertion("toUpperTest output mismatch", output, expectedStr)

    // Assert that the input buffer wasn't modified
    cobhan.TestStringAssertion("toUpperTest input buffer modified", input, testStr)

    fmt.Println("toUpperTest passed")
}

func toUpperTempTest() {
    // Simulate FFI Parameters
    input := cobhan.TestAllocateStringBuffer(testStr)
    defer cobhan.TestFreeBuffer(input)

    output := cobhan.TestAllocateBuffer(len(testStr) - 1) // Make it too small so a temp file is used
    defer cobhan.TestFreeBuffer(output)

    result := toUpper(input, output)
    if result < cobhan.ERR_NONE {
        panic(fmt.Sprintf("toUpperTest failed: Result: %d", result))
    }

    expectedStr := strings.ToUpper(testStr)
    cobhan.TestStringAssertion("toUpperTest output mismatch", output, expectedStr)

    // Assert that the input buffer wasn't modified
    cobhan.TestStringAssertion("toUpperTest input buffer modified", input, testStr)

    fmt.Println("toUpperTempTest passed")
}

func filterJsonTest() {
    inputJsonStr := `
    {
        "Name": "Anna",
        "Age": 18,
        "Movie": "Frozen 2"
    }`

    inputJson := cobhan.TestAllocateStringBuffer(inputJsonStr)
    defer cobhan.TestFreeBuffer(inputJson)

    disallowedValueStr := "Frozen"
    disallowedValue := cobhan.TestAllocateStringBuffer(disallowedValueStr)
    defer cobhan.TestFreeBuffer(disallowedValue)

    outputJson := cobhan.TestAllocateBuffer(len(inputJsonStr) * 2)
    defer cobhan.TestFreeBuffer(outputJson)

    result := filterJson(inputJson, disallowedValue, outputJson)
    if result < 0 {
        panic(fmt.Sprintf("filterJson failed: Result: %d", result))
    }

    cobhan.TestStringNotAssertion("disallowed value filtered", outputJson, disallowedValueStr)
    fmt.Println("filterJsonTest passed")
}

func allocationTest() {
    buffer := cobhan.TestAllocateBuffer(1024)
    cobhan.TestFreeBuffer(buffer)
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
