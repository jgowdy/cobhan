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

func allocateTestCharStar(size int32) *C.char {
	return (*C.char)(C.malloc(C.ulong(size)))
}

func freeTestCharStar(ptr *C.char) {
	C.free(unsafe.Pointer(ptr))
}
