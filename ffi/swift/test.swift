#!/usr/bin/swift

import Darwin

let handle = dlopen("/Users/jgowdy/projects/cobhan/library/rust/libplugtest/target/debug/libplugtest.dylib", RTLD_NOW);

typealias addInt32Func = @convention(c) (Int32, Int32) -> Int32
typealias addInt64Func = @convention(c) (Int64, Int64) -> Int64
typealias addDoubleFunc = @convention(c) (Float64, Float64) -> Float64
typealias sleepTestFunc = @convention(c) (Int32) -> Void

var sym = dlsym(handle, "addInt32")
let addInt32 = unsafeBitCast(sym, to: addInt32Func.self)

sym = dlsym(handle, "addInt64")
let addInt64 = unsafeBitCast(sym, to: addInt64Func.self)

sym = dlsym(handle, "addDouble")
let addDouble = unsafeBitCast(sym, to: addDoubleFunc.self)

sym = dlsym(handle, "sleepTest")
let sleepTest = unsafeBitCast(sym, to: sleepTestFunc.self)

let resultInt32 = addInt32(1,2)
print(resultInt32)

let resultInt64 = addInt64(1,2)
print(resultInt64)

let resultDouble = addDouble(1.1, 2.2)
print(resultDouble)

print("Sleeping for 5 seconds")
sleepTest(5)
print("Finished sleeping")

dlclose(handle)
