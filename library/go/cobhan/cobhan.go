package cobhan

import (
    "C"
    "encoding/json"
    "reflect"
    "unsafe"
    "io/ioutil"
)

//Types:
/*
    Supported scalar types:
        int32 - 32 bit signed integer
        int64 - 64 bit signed integer
        float64 - double precision 64 bit IEEE 754 floating point

    Supported buffer types:
        string - utf-8 encoded length delimited string
        JSON - utf-8 encoded length delimited string containing valid JSON
        []byte - 8 bit raw binary buffer

    Buffer passing requirements:
        * All buffers are passed as pointers + signed int32 lengths (length delimited)
        * Callers may optionally append null to strings or JSON but must not include the null in the length
        * No guarantee of null termination on returned output buffers
        * Callers provide the output buffer allocation and capacity
        * Callers can re-use the input buffer as the output buffer (memmove/copy semantics)
        * Insufficient capacity in output buffer causes functions to fail by returning less than zero

    Output buffer sizing:
        * Callers may know the appropriate output buffer size
            * If it is a fixed / constant documented size
            * If it matches the input buffer size
            * If it can be computed from the input buffer size in an documented fashion (e.g. Base64)
            * If the library provides a method that returns the output buffer size for a provided input buffer size

        * When output buffer size cannot be predicted easily callers may utilize a buffer pool with a tuned
            buffer size that covers most rational cases

    * When functions return insufficient buffer errors (should be rare) caller can allocate increasing buffer
            sizes up to a maximum size, retrying until the operation is successful

    Return values:
        * Functions that return scalar values can return the value directly
            * Functions *can* use special case and return maximum positive or maximum negative or zero values to
                represent error or overflow conditions
            * Functions *can* allow scalar values to wrap, which is the default behavior in Go
            * Functions should document their overflow / underflow behavior

        * Functions that return buffer values should return an int32 containing the populated output buffer length or
            an error code if the value is less than zero

*/

type Buffer *C.char

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

func InputBytes(srcPtr Buffer, srcLen int32, max int) ([]byte, int32) {
    if uintptr(unsafe.Pointer(srcPtr)) == 0 {
        return nil, ERR_NULL_PTR
    }

    if int(srcLen) > max {
        return nil, ERR_INPUT_BUFFER_TOO_LARGE
    }

    return C.GoBytes(unsafe.Pointer(srcPtr), C.int(srcLen)), 0
}

func InputString(srcPtr Buffer, srcLen int32, max int) (string, int32) {
    if uintptr(unsafe.Pointer(srcPtr)) == 0 {
        return "", ERR_NULL_PTR
    }

    if int(srcLen) > max {
        return "", ERR_INPUT_BUFFER_TOO_LARGE
    }

    return C.GoStringN(srcPtr, C.int(srcLen)), 0
}

func InputJson(srcPtr Buffer, srcLen int32, max int) (map[string]interface{}, int32) {
    var loadedJson interface{}
    err := json.Unmarshal([]byte(C.GoStringN(srcPtr, C.int(srcLen))), &loadedJson)
    if err != nil {
        return nil, ERR_JSON_INPUT_DECODE_FAILED
    }
    return loadedJson.(map[string]interface{}), 0
}

func OutputBytes(src []byte, dstPtr Buffer, dstCap int32) int32 {
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

func OutputString(str string, dstPtr Buffer, dstCap int32) int32 {
    return OutputBytes([]byte(str), dstPtr, dstCap)
}

func OutputJson(v interface{}, dstPtr Buffer, dstCap int32) int32 {
    outputBytes, err := json.Marshal(v)
    if err != nil {
        return ERR_JSON_OUTPUT_ENCODE_FAILED
    }
    return OutputBytes(outputBytes, dstPtr, dstCap)
}
