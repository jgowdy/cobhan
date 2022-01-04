import { toUpper, filterJsonObject, addInt32, addInt64, addDouble, sleepTest } from 'cobhan-demo-lib';

console.log(toUpper('Initial value'));

let output = filterJsonObject({ test: 'foo', test2: 'kittens' } , 'foo');
console.log(output);

// Intentionally showing integer behavior Number is truncation, not rounding
console.log(addInt32(2.9, 2.0));
console.log(addInt64(2.9, 2.0));

// Double is the same as Number
console.log(addDouble(2.9, 2.0));

// Test using a Promise to call a blocking function
console.log('Start sleeping');
sleepTest(2).then(() => {
        console.log('Finished sleeping');
    })
