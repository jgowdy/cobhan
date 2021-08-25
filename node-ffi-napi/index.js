var ffi = require('ffi-napi');
var process = require('process');

var os_path;
switch (process.platform.toLowerCase()) {
    case 'win32':
        os_path = 'windows';
        break;
    case 'linux':
        os_path = 'linux';
        break;
    case 'darwin':
        os_path = 'macos';
        break;
    default:
        throw 'Unsupported operating system';
}

var arch_path;
switch (process.arch.toLowerCase()) {
    case 'arm64':
        arch_path = 'arm64';
        break;
    case 'x64':
        arch_path = 'amd64';
        break;
    default:
        throw 'Unsupported architecture';
}


var libplugtest = ffi.Library('../output/' + os_path + '/' + arch_path + '/libplugtest', {
    'toUpper': ['void', ['char *']]
});

var maxStringLength = 200;
var theStringBuffer = Buffer.allocUnsafe(maxStringLength);
theStringBuffer.fill(0); //if you want to initially clear the buffer
theStringBuffer.write("Initial value", 0, "utf-8"); //if you want to give it an initial value

//call the function
libplugtest.toUpper(theStringBuffer);

//retrieve and convert the result back to a javascript string
var theString = theStringBuffer.toString('utf-8');
var terminatingNullPos = theString.indexOf('\u0000');
if (terminatingNullPos >= 0) {
    theString = theString.substr(0, terminatingNullPos);
}

console.log(theString)