const libplugtest = require('libplugtestjs');

console.log(libplugtest.toUpperInGo('Initial value'));

let output = libplugtest.filterJsonObjectInGo({ test: 'foo', test2: 'kittens' } , 'foo');
console.log(output);

console.log(libplugtest.addInt32InGo(2.9, 2.0));
console.log(libplugtest.addInt64InGo(2.9, 2.0));

console.log(libplugtest.addDoubleInGo(2.9, 2.0));

console.log('Start sleeping');
libplugtest.sleepInGo(2).then(function(result) {
  console.log('Finished sleeping');
})
