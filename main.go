package main

// #cgo CFLAGS: -g -Wall
// #include "toupper.h"
// #include <dlfcn.h>
import "C"

//export toUpper
func toUpper(input *C.char) {
	C.toUpperInC(input)
}

func main() {
}
