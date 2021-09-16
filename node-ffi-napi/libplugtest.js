const process = require('process');
const path = require("path");
const fs = require("fs");

var initialized = false;

var ffi, libplugtest;

function initialize() {
    if (initialized) {
        throw 'Called initialize() again';
    }
    initialized = true;

    let os_path = { 'win32': 'windows', 'linux': 'linux', 'darwin': 'macos' }[process.platform.toLowerCase()];
    if (typeof os_path === 'undefined') {
        throw 'Unsupported operating system'
    }

    if (os_path == 'linux') {
        var files = fs.readdirSync('/lib').filter(fn => fn.startsWith('libc.musl'));
        if (files.length > 0) {
            os_path = 'linux-musl';
        }
    }

    let arch_path = { 'arm64': 'arm64', 'x64': 'amd64' }[process.arch.toLowerCase()];
    if (typeof arch_path === 'undefined') {
        throw 'Unsupported architecture';
    }

    let libpath = path.resolve('../output/' + os_path + '/' + arch_path + '/');
    let libplugtestpath = path.join(libpath, 'libplugtest');

    console.log('Loading ffi-napi');
    ffi = require('ffi-napi');

    let old_cwd = process.cwd();
    console.log(`Saving existing working directory ${old_cwd}`);
    console.log(`Changing to working directory ${libpath}`);
    process.chdir(libpath);

    console.log(`Calling ffi.Library(${libplugtestpath}`);

    libplugtest = ffi.Library(libplugtestpath, {
        'calculatePi': ['int32', ['int32', 'char *', 'int32']],
        'sleepTest': ['void', ['int32']],
        'addInt32': ['int32', ['int32', 'int32']],
        'addInt64': ['int64', ['int64', 'int64']],
        'addDouble': ['double', ['double', 'double']],
    });

    libplugtestPointerInputs = ffi.Library(libplugtestpath, {
        'toUpper': ['int32', ['char *', 'int32', 'char *', 'int32']]
    });

    libplugtestStringInputs = ffi.Library(libplugtestpath, {
        'toUpper': ['int32', ['string', 'int32', 'char *', 'int32']]
    });

    console.log(`Restoring old working directory ${old_cwd}`)
    process.chdir(old_cwd);
}

const constStr = 'Should Never Change';

// ***********************************************************************************************************
// Pointer input declarations
// ***********************************************************************************************************

/**
 * @param {string} str
 */
function toUpperInGoPointerInputsCreateCString(str) {
    if (!initialized) {
        throw 'libplugtest was not initialized';
    }

    // Create null delimited C string
    let buf = Buffer.allocUnsafe(str.length + 1);
    buf.writeCString(str);

    //Must use buf.byteLength - 1 because of included null
    let result = libplugtestPointerInputs.toUpper(buf, buf.byteLength - 1, buf, buf.byteLength);
    if (result < 0) {
        throw 'toUpperMutableNullDelimited failed: ' + result
    }

    return buf.toString('utf-8', 0, result)
}


/**
 * @param {string} str
 */
 function toUpperInGoPointerInputsBufferFrom(str) {
    if (!initialized) {
        throw 'libplugtest was not initialized';
    }

    // Create length delimited buffer
    let buf = Buffer.from(str)

    let result = libplugtestPointerInputs.toUpper(buf, buf.byteLength, buf, buf.byteLength);
    if (result < 0) {
        throw 'toUpperMutableLengthDelimited failed: ' + result
    }

    return buf.toString('utf-8', 0, result)
}

/**
 * @param {string} str
 */
function toUpperInGoPointerInputsBufferFromBufferAllocUnsafe(str) {
    if (!initialized) {
        throw 'libplugtest was not initialized';
    }

    // Create length delimited buffer
    let buf = Buffer.from(str)

    //Create output buffer
    let out = Buffer.allocUnsafe(buf.length + 1) //Pad this for demonstration purposes

    let result = libplugtestPointerInputs.toUpper(buf, buf.length, out, out.length);
    if (result < 0) {
        throw 'toUpperLengthDelimitedToOutputBuffer failed: ' + result
    }

    return out.toString('utf-8', 0, result)
}

// ***********************************************************************************************************
// String input declarations
// ***********************************************************************************************************

/**
 * @param {string} str
 */
 function toUpperInGoStringInputsCreateCString(str) {
    if (!initialized) {
        throw 'libplugtest was not initialized';
    }

    // Create null delimited C string
    let buf = Buffer.allocUnsafe(str.length + 1);
    buf.writeCString(str);

    let result = libplugtestStringInputs.toUpper(buf);
    if (result < 0) {
        throw 'toUpperMutableNullDelimited failed: ' + result
    }

    return buf.toString('utf-8', 0, result)
}

/**
 * @param {string} str
 */
 function toUpperInGoStringInputsBufferFrom(str) {
    if (!initialized) {
        throw 'libplugtest was not initialized';
    }

    // Create length delimited buffer
    let buf = Buffer.from(str)

    let result = libplugtestStringInputs.toUpper(buf, buf.length);
    if (result < 0) {
        throw 'toUpperMutableLengthDelimited failed: ' + result
    }

    return buf.toString('utf-8', 0, result)
}

/**
 * @param {string} str
 */
function toUpperInGoStringInputsPassStringDirectlyBufferAllocUnsafe(str) {
    if (!initialized) {
        throw 'libplugtest was not initialized';
    }

    // Create output buffer
    let out = Buffer.allocUnsafe(str.length + 1) //Pad this for demonstration purposes

    let result = libplugtestStringInputs.toUpper(str, out, out.length);
    if (result < 0) {
        throw 'toUpperNullDelimitedToOutputBuffer failed: ' + result
    }

    return out.toString('utf-8', 0, result);
}

/**
 * @param {string} str
 */
function toUpperInGoStringInputsBufferFromBufferAllocUnsafe(str) {
    if (!initialized) {
        throw 'libplugtest was not initialized';
    }

    // Create length delimited buffer
    let buf = Buffer.from(str)

    //Create output buffer
    let out = Buffer.allocUnsafe(buf.length + 1) //Pad this for demonstration purposes

    let result = libplugtestStringInputs.toUpper(buf, buf.length, out, out.length);
    if (result < 0) {
        throw 'toUpperLengthDelimitedToOutputBuffer failed: ' + result
    }

    return out.toString('utf-8', 0, result)
}

// ***********************************************************************************************************
// Non-string functions
// ***********************************************************************************************************

/**
 * @param {number} x
 * @param {number} y
 */
 function addInt32InGo(x, y) {
    return libplugtest.addInt32(x, y);
}

/**
 * @param {number} x
 * @param {number} y
 */
 function addInt64InGo(x, y) {

    return libplugtest.addInt64(x, y);
}

/**
 * @param {number} x
 * @param {number} y
 */
 function addDoubleInGo(x, y) {
    return libplugtest.addDouble(x, y);
}

/**
 * @param {number} seconds
 */
function sleepInGo(seconds) {
    if (!initialized) {
        throw 'libplugtest was not initialized';
    }
    return new Promise((resolve) => {
        libplugtest.sleepTest.async(seconds, () => {
            resolve();
        });
    });
}

initialize();

module.exports = {
    toUpperInGoPointerInputsCreateCString,
    toUpperInGoPointerInputsBufferFrom,
    toUpperInGoPointerInputsBufferFromBufferAllocUnsafe,
    toUpperInGoStringInputsCreateCString,
    toUpperInGoStringInputsBufferFrom,
    toUpperInGoStringInputsPassStringDirectlyBufferAllocUnsafe,
    toUpperInGoStringInputsBufferFromBufferAllocUnsafe,
    sleepInGo, addInt32InGo, addInt64InGo, addDoubleInGo };
