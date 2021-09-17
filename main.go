package main

import (
	"fmt"
	"reflect"
	"strings"
	"time"
	"unsafe"
)

/*
#include <stdlib.h> //For C.free
*/
import (
	"C"
)

// Sample exports for client testing

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

// String passing requirements
// * All strings are passed as pointers + signed int32 lengths (length delimited)
// * Callers may append null to strings but we do not
// * Callers provide the output buffer and capacity
// * Callers can re-use the input buffer as the output buffer (memmove semantics)
// * Insufficient capacity in output buffer causes functions to fail by returning less than zero

const TOO_SMALL = -1
const COPY_FAIL = -2

//export toUpper
func toUpper(input *C.char, inputLen int32, output *C.char, outputCap int32) int32 {
	str := C.GoStringN(input, (C.int)(inputLen))
	str = strings.ToUpper(str)
	return (int32)(CopyStringToCStr(str, output, (int)(outputCap)))
}

const SCALE = int64(10000000)
const ARRINIT = int64(2000000)

//export calculatePi
func calculatePi(digits int32, output *C.char, outputCap int32) int32 {
	pi := strings.Builder{}
	digitsInt64 := (int64)(digits)

	//arraySize := digitsInt64 + 1
	arraySize := digitsInt64 * 2
	arr := make([]int64, arraySize)
	carry := int64(0)

	for i := int64(0); i <= digitsInt64; i++ {
		arr[i] = ARRINIT
	}

	for i := digitsInt64; i > 0; i -= 14 {
		sum := int64(0)
		for j := i; j > 0; j-- {
			sum = sum*j + SCALE*arr[j]
			arr[j] = sum % (j*2 - 1)
			sum /= j*2 - 1
		}
		pi.WriteString(fmt.Sprintf("%04d", carry+sum/SCALE))
		carry = sum % SCALE
	}

	return int32(CopyStringToCStr(pi.String(), output, int(outputCap)))
}

// Reusable functions to facilitate FFI

func CopyStringToCStr(str string, dstPtr *C.char, dstCap int) int {
	strLen := len(str)
	if dstCap < strLen {
		return TOO_SMALL //Insufficient output buffer capacity
	}

	src := ([]byte)(str)

	var dst []byte
	sh := (*reflect.SliceHeader)(unsafe.Pointer(&dst))
	sh.Data = (uintptr)(unsafe.Pointer(dstPtr))
	sh.Len = dstCap
	sh.Cap = dstCap

	result := copy(dst, src)

	if result != strLen {
		return COPY_FAIL //Failed to copy the expected number of bytes
	}

	//Return number of bytes copied to destination
	return result
}

// Test functions

const testStr = "Test String"

func allocateTestCharStar(size int32) *C.char {
	return (*C.char)(C.malloc(C.ulong(size)))
}

func freeTestCharStar(ptr *C.char) {
	C.free(unsafe.Pointer(ptr))
}

func toUpperTest() {
	// Simulate FFI Parameters
	input := C.CString(testStr) // This is a copy
	defer C.free(unsafe.Pointer(input))
	inputLen := (int32)(len(testStr))
	outputCap := (int32)(2048)
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

func calculatePiTest() {
	digits := int32(20000)

	//Simulate FFI Parameters
	outputCap := digits + 1
	output := allocateTestCharStar(outputCap)
	defer freeTestCharStar(output)

	result := calculatePi(digits, output, outputCap)

	if result < 0 {
		panic(fmt.Sprintf("Failed to calculate %d digits of pi", digits))
	}
	fmt.Println(result)

	outputStr := C.GoStringN(output, (C.int)(result))
	fmt.Println(outputStr)
}

func main() {
	toUpperTest()
	calculatePiTest()
}
