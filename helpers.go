package main

import (
	"C"
	"encoding/json"
	"reflect"
	"unsafe"
)

type buffer *C.char

//One of the provided input pointers is NULL / nil / 0
const ERR_NULL_PTR = -1

//One of the provided input buffer lengths is too large
const ERR_INPUT_BUFFER_TOO_LARGE = -2

//One of the provided output buffers was too small to receive the output
const ERR_OUTPUT_BUFFER_TOO_SMALL = -3

//Failed to copy the output into the output buffer (copy length != expected length)
const ERR_COPY_FAILED = -4

//Failed to decode a JSON input buffer
const ERR_JSON_INPUT_DECODE_FAILED = -5

//Failed to encode to JSON output buffer
const ERR_JSON_OUTPUT_ENCODE_FAILED = -6

// Reusable functions to facilitate FFI

func InputBytes(srcPtr buffer, srcLen int32, max int) ([]byte, int32) {
	if uintptr(unsafe.Pointer(srcPtr)) == 0 {
		return nil, ERR_NULL_PTR
	}

	if int(srcLen) > max {
		return nil, ERR_INPUT_BUFFER_TOO_LARGE
	}

	return C.GoBytes(unsafe.Pointer(srcPtr), C.int(srcLen)), 0
}

func InputString(srcPtr buffer, srcLen int32, max int) (string, int32) {
	if uintptr(unsafe.Pointer(srcPtr)) == 0 {
		return "", ERR_NULL_PTR
	}

	if int(srcLen) > max {
		return "", ERR_INPUT_BUFFER_TOO_LARGE
	}

	return C.GoStringN(srcPtr, C.int(srcLen)), 0
}

func InputJson(srcPtr buffer, srcLen int32, max int) (map[string]interface{}, int32) {
	var loadedJson interface{}
	err := json.Unmarshal([]byte(C.GoStringN(srcPtr, C.int(srcLen))), &loadedJson)
	if err != nil {
		return nil, ERR_JSON_INPUT_DECODE_FAILED
	}
	return loadedJson.(map[string]interface{}), 0
}

func OutputBytes(src []byte, dstPtr buffer, dstCap int32) int32 {
	dstCapInt := int(dstCap)
	srcLen := len(src)
	if dstCapInt < srcLen {
		return ERR_OUTPUT_BUFFER_TOO_SMALL
	}

	var dst []byte
	sh := (*reflect.SliceHeader)(unsafe.Pointer(&dst))
	sh.Data = (uintptr)(unsafe.Pointer(dstPtr))
	sh.Len = dstCapInt
	sh.Cap = dstCapInt

	result := copy(dst, src)

	if result != srcLen {
		return ERR_COPY_FAILED //Failed to copy the expected number of bytes
	}

	//Return number of bytes copied to destination
	return int32(result)
}

func OutputString(str string, dstPtr buffer, dstCap int32) int32 {
	return OutputBytes([]byte(str), dstPtr, dstCap)
}

func OutputJson(v interface{}, dstPtr buffer, dstCap int32) int32 {
	outputBytes, err := json.Marshal(v)
	if err != nil {
		return ERR_JSON_OUTPUT_ENCODE_FAILED
	}
	return OutputBytes(outputBytes, dstPtr, dstCap)
}
