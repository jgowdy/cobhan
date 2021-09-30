package main

import (
	"unsafe"
)

/*
#include <stdlib.h> //For C.free
*/
import (
	"C"
)

func allocateTestBuffer(size int32) buffer {
	return (buffer)(C.malloc(C.ulong(size)))
}

func freeTestBuffer(ptr buffer) {
	C.free(unsafe.Pointer(ptr))
}
