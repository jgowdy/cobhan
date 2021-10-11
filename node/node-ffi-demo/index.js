import { toUpperInGo, filterJsonObjectInGo, addInt32InGo, addInt64InGo, addDoubleInGo, sleepInGo } from 'libplugtestjs';

console.log(toUpperInGo('Initial value'));

let output = filterJsonObjectInGo({ test: 'foo', test2: 'kittens' } , 'foo');
console.log(output);

// Intentionally showing integer behavior Number is truncation, not rounding
console.log(addInt32InGo(2.9, 2.0));
console.log(addInt64InGo(2.9, 2.0));

// Double is the same as Number
console.log(addDoubleInGo(2.9, 2.0));

// Test using a Promise to call a blocking function
console.log('Start sleeping');
sleepInGo(2).then(function(result) {
  console.log('Finished sleeping');
})
