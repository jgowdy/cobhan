import { toUpperInGo, filterJsonObjectInGo, addInt32InGo, addInt64InGo, addDoubleInGo, sleepInGo } from 'libplugtestjs';

console.log(toUpperInGo('Initial value'));

let output = filterJsonObjectInGo({ test: 'foo', test2: 'kittens' } , 'foo');
console.log(output);

console.log(addInt32InGo(2.9, 2.0));
console.log(addInt64InGo(2.9, 2.0));

console.log(addDoubleInGo(2.9, 2.0));

console.log('Start sleeping');
sleepInGo(2).then(function(result) {
  console.log('Finished sleeping');
})
