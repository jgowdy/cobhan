package main

import (
	"C"
	"encoding/json"
	"fmt"
	"reflect"
	"unsafe"
)

// Reusable functions to facilitate FFI

func GoString(srcPtr *C.char, srcLen int32) (string, error) {
	if uintptr(unsafe.Pointer(srcPtr)) == 0 {
		return "", fmt.Errorf("pointer is null")
	}

	return C.GoStringN(srcPtr, C.int(srcLen)), nil
}

func LoadJson(srcPtr *C.char, srcLen int32) (map[string]interface{}, error) {
	var loadedJson interface{}
	err := json.Unmarshal([]byte(C.GoStringN(srcPtr, C.int(srcLen))), &loadedJson)
	if err != nil {
		return nil, err
	}
	return loadedJson.(map[string]interface{}), nil
}

func CopyBytesToCStr(src []byte, dstPtr *C.char, dstCap int32) int32 {
	dstCapInt := int(dstCap)
	srcLen := len(src)
	if dstCapInt < srcLen {
		return TOO_SMALL //Insufficient output buffer capacity
	}

	var dst []byte
	sh := (*reflect.SliceHeader)(unsafe.Pointer(&dst))
	sh.Data = (uintptr)(unsafe.Pointer(dstPtr))
	sh.Len = dstCapInt
	sh.Cap = dstCapInt

	result := copy(dst, src)

	if result != srcLen {
		return COPY_FAIL //Failed to copy the expected number of bytes
	}

	//Return number of bytes copied to destination
	return int32(result)
}

func CopyStringToCStr(str string, dstPtr *C.char, dstCap int32) int32 {
	return CopyBytesToCStr([]byte(str), dstPtr, dstCap)
}
