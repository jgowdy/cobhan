
let libplugtest = require('libplugtestjs');

libplugtest.initializeLibPlugTest("../libplugtest-binaries/")

console.log(libplugtest.toUpperInGoPointerInputsBufferFrom('Initial value'));
console.log(libplugtest.toUpperInGoPointerInputsBufferFromBufferAllocUnsafe('Initial value'));
console.log(libplugtest.toUpperInGoPointerInputsCreateCString('Initial value'));

console.log(libplugtest.toUpperInGoStringInputsBufferFrom('Initial value'));
console.log(libplugtest.toUpperInGoStringInputsBufferFromBufferAllocUnsafe('Initial value'));
console.log(libplugtest.toUpperInGoStringInputsCreateCString('Initial value'));
console.log(libplugtest.toUpperInGoStringInputsPassStringDirectlyBufferAllocUnsafe('Initial value'));

// These seem to undergo truncation before being passed as integers, not rounding
console.log(libplugtest.addInt32InGo(2.9, 2.0));
console.log(libplugtest.addInt64InGo(2.9, 2.0));

console.log(libplugtest.addDoubleInGo(2.9, 2.0));


console.log("Start sleeping");
libplugtest.sleepInGo(2).then(function(result) {
  console.log("Finished sleeping");
})
