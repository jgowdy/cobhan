
let libplugtest = require('libplugtestjs');

libplugtest.initializeLibPlugTest("../output/")

console.log(libplugtest.toUpperInGoPointerInputsBufferFrom('Initial value'));
console.log(libplugtest.toUpperInGoPointerInputsBufferFromBufferAllocUnsafe('Initial value'));
console.log(libplugtest.toUpperInGoPointerInputsCreateCString('Initial value'));

// Runtime errors (rightly so)
/*console.log(libplugtest.toUpperInGoPointerInputsPassMutableStringDirectly('Initial value'));*/
/*console.log(libplugtest.toUpperInGoPointerInputsPassMutableStringDirectlyWithLength('Initial value'));*/
/*console.log(libplugtest.toUpperInGoPointerInputsPassStringDirectlyBufferAllocUnsafe('Initial value'));*/

console.log(libplugtest.toUpperInGoStringInputsBufferFrom('Initial value'));
console.log(libplugtest.toUpperInGoStringInputsBufferFromBufferAllocUnsafe('Initial value'));
console.log(libplugtest.toUpperInGoStringInputsCreateCString('Initial value'));
console.log(libplugtest.toUpperInGoStringInputsPassStringDirectlyBufferAllocUnsafe('Initial value'));

// These don't work (return unmodified strings) because they mutate a copy of the string made by ffi-napi since strings are immutable
//console.log(libplugtest.toUpperInGoStringInputsPassMutableStringDirectly('Initial value'));
//console.log(libplugtest.toUpperInGoStringInputsPassMutableStringDirectlyWithLength('Initial value'));

// These seem to undergo truncation before being passed as integers, not rounding
console.log(libplugtest.addInt32InGo(2.9, 2.0));
console.log(libplugtest.addInt64InGo(2.9, 2.0));

console.log(libplugtest.addDoubleInGo(2.9, 2.0));


//let libplugtest = require("./libplugtest");
//let threadplugtest = require("./threadplugtest");

//console.log("Start sleeping");
//libplugtest.sleepInGo(10).then(function(result) {
//  console.log("Finished sleeping");
//})

//console.log(libplugtest.toUpperInGo('Initial value'));

//console.log("Waiting for promise to complete?");
/*
threadplugtest('test').then(function(result) {
  console.log("Finished threaded test with result: " + result);
});
*/
