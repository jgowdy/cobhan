package cobhan

import (
	"fmt"
	"strings"
	"unsafe"
)

/*
#include <stdlib.h> //For C.free
*/
import (
	"C"
)

func TestStringAssertion(desc string, buf unsafe.Pointer, expected string) {
	str, result := BufferToString(buf)
	if result < 0 {
		panic(fmt.Sprintf("Assert %s failed: BufferToString failed", desc))
	}

	if str != expected {
		panic(fmt.Sprintf("Assert %s failed: Value: %s Expected: %s", desc, str, expected))
	}
}

func TestStringNotAssertion(desc string, buf unsafe.Pointer, disallowed string) {
	str, result := BufferToString(buf)
	if result < 0 {
		panic(fmt.Sprintf("Assert %s failed: BufferToString failed", desc))
	}

	if strings.Contains(str, disallowed) {
		panic(fmt.Sprintf("Assert %s failed: Found %s in value: %s", desc, disallowed, str))
	}
}

func TestAllocateStringBuffer(str string) unsafe.Pointer {
	buf := TestAllocateBuffer(len(str))
	result := StringToBuffer(str, buf)
	if result < ERR_NONE {
		panic(fmt.Sprintf("TestAllocateStringBuffer failed: %d", result))
	}
	return buf
}

func TestAllocateBuffer(size int) unsafe.Pointer {
	ptr := C.malloc(C.ulong(size + BUFFER_HEADER_SIZE))
	*(*int32)(ptr) = int32(size)
	return ptr
}

func TestFreeBuffer(ptr unsafe.Pointer) {
	C.free(ptr)
}
