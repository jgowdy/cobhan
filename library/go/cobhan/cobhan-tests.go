package cobhan

import (
    "unsafe"
    "fmt"
    "strings"
)

/*
#include <stdlib.h> //For C.free
*/
import (
	"C"
)

func TestAllocateStringBuffer(str string) Buffer {
    return (Buffer)(C.CString(str))
}

func TestAllocateBuffer(size int32) Buffer {
	return (Buffer)(C.malloc(C.ulong(size)))
}

func TestFreeBuffer(ptr Buffer) {
	C.free(unsafe.Pointer(ptr))
}

func TestStringAssertion(desc string, buf Buffer, bufLen int32, expected string) {
    str := C.GoStringN(buf, (C.int)(bufLen))
	if str != expected {
		panic(fmt.Sprintf("Assert %s failed: Value: %s Expected: %s", desc, str, expected))
	}
}

func TestStringNotAssertion(desc string, buf Buffer, bufLen int32, disallowed string) {
    str := C.GoStringN(buf, C.int(bufLen))
	if strings.Contains(str, disallowed) {
		panic("Assert %s failed: Found %s in value: %s")
	}
}

func TestToGoStringN(buf Buffer, bufLen int32) string {
    return C.GoStringN(buf, (C.int)(bufLen))
}
