package cobhan

import (
	"fmt"
	"reflect"
	"strings"
	"unsafe"
)

/*
#include <stdlib.h> //For C.free
*/
import (
	"C"
)

func TestStringAssertion(desc string, buf Buffer, expected string) {
	ptr := unsafe.Pointer(buf)
	length := C.int(*(*int32)(ptr))
	dataPtr := unsafe.Pointer(uintptr(ptr) + BUFFER_HEADER_SIZE)
	str := C.GoStringN((*C.char)(dataPtr), length)
	if str != expected {
		panic(fmt.Sprintf("Assert %s failed: Value: %s Expected: %s", desc, str, expected))
	}
}

func TestStringNotAssertion(desc string, buf Buffer, disallowed string) {
	ptr := unsafe.Pointer(buf)
	length := C.int(*(*int32)(ptr))
	dataPtr := unsafe.Pointer(uintptr(ptr) + BUFFER_HEADER_SIZE)
	str := C.GoStringN((*C.char)(dataPtr), length)
	if strings.Contains(str, disallowed) {
		panic("Assert %s failed: Found %s in value: %s")
	}
}

func TestToGoStringN(buf Buffer) string {
	ptr := unsafe.Pointer(buf)
	length := C.int(*(*int32)(ptr))
	dataPtr := unsafe.Pointer(uintptr(ptr) + BUFFER_HEADER_SIZE)
	return C.GoStringN((*C.char)(dataPtr), length)
}

func TestAllocateStringBuffer(str string) Buffer {
	strLen := len(str)
	ptr := C.malloc(C.ulong(BUFFER_HEADER_SIZE + strLen))

	var dst []byte
	sh := (*reflect.SliceHeader)(unsafe.Pointer(&dst))
	sh.Data = (uintptr)(unsafe.Pointer(uintptr(ptr) + BUFFER_HEADER_SIZE))
	sh.Len = strLen
	sh.Cap = strLen
	result := copy(dst, ([]byte)(str))
	if result != strLen {
		panic("Failed to copy test string")
	}
	return (Buffer)(ptr)
}

func TestAllocateOutputBuffer(size int) Buffer {
	return (Buffer)(C.malloc(C.ulong(size + BUFFER_HEADER_SIZE)))
}

func TestFreeBuffer(ptr Buffer) {
	C.free(unsafe.Pointer(ptr))
}
