//
//  main.swift
//  libplugtest-console
//
//  Created by Jeremiah Gowdy on 10/13/21.
//

//#!/usr/bin/swift

//NOTE: Requires Disable library validation in XCode projects for dlopen of unsigned dylib

import Darwin
let handle = dlopen("/Users/jgowdy/projects/cobhan/library/rust/libplugtest/target/debug/libplugtest.dylib", RTLD_NOW)

let alignment = MemoryLayout<CChar>.alignment

typealias addInt32Func = @convention(c) (Int32, Int32) -> Int32
typealias addInt64Func = @convention(c) (Int64, Int64) -> Int64
typealias addDoubleFunc = @convention(c) (Float64, Float64) -> Float64
typealias sleepTestFunc = @convention(c) (Int32) -> Void
typealias toUpperFunc = @convention(c) (UnsafePointer<CChar>, Int32, UnsafeMutableRawPointer, Int32) -> Int32

var sym = dlsym(handle, "addInt32")
let addInt32 = unsafeBitCast(sym, to: addInt32Func.self)

sym = dlsym(handle, "addInt64")
let addInt64 = unsafeBitCast(sym, to: addInt64Func.self)

sym = dlsym(handle, "addDouble")
let addDouble = unsafeBitCast(sym, to: addDoubleFunc.self)

sym = dlsym(handle, "sleepTest")
let sleepTest = unsafeBitCast(sym, to: sleepTestFunc.self)

sym = dlsym(handle, "toUpper")
let toUpper = unsafeBitCast(sym, to: toUpperFunc.self)

let resultInt32 = addInt32(1,2)
print(resultInt32)

let resultInt64 = addInt64(1,2)
print(resultInt64)

let resultDouble = addDouble(1.1, 2.2)
print(resultDouble)

let input = "Initial value"
let inputLen = input.utf8.count
let outputPtr = UnsafeMutableRawPointer.allocate(byteCount: inputLen,  alignment: alignment)
defer { outputPtr.deallocate() }
let result = toUpper(input, Int32(inputLen), outputPtr, Int32(inputLen))
if result < 0 {
    print ("toUpper failed")
    abort()
}

let output = String(unsafeUninitializedCapacity: inputLen) { (bytes: UnsafeMutableBufferPointer<UInt8>) -> Int in
    memcpy(bytes.baseAddress, outputPtr, inputLen)
    return inputLen
}

print(output)

print("Sleeping for 5 seconds")
sleepTest(5)
print("Finished sleeping")

dlclose(handle)
