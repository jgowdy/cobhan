var ffi = require('ffi-napi');

var libplugtest = ffi.Library('../libplugtest', {
    'toUpperInC': ['void', ['char *']]
});

var maxStringLength = 200;
var theStringBuffer = Buffer.allocUnsafe(maxStringLength);
theStringBuffer.fill(0); //if you want to initially clear the buffer
theStringBuffer.write("Initial value", 0, "utf-8"); //if you want to give it an initial value

//call the function
libplugtest.toUpperInC(theStringBuffer);

//retrieve and convert the result back to a javascript string
var theString = theStringBuffer.toString('utf-8');
var terminatingNullPos = theString.indexOf('\u0000');
if (terminatingNullPos >= 0) {
    theString = theString.substr(0, terminatingNullPos);
}

console.log(theString)