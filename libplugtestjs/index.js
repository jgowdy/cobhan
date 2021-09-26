/* eslint-disable max-len */
const process = require('process');
const path = require('path');
const fs = require('fs');

let initialized = false;
let ffi; let libplugtest;

/**
*/
function initializeLibPlugTest() {
  initialized = true;

  const libraryRootPath = path.join(__dirname, 'libplugtest-binaries');

  let osPath = {'win32': 'windows', 'linux': 'linux', 'darwin': 'macos'}[process.platform.toLowerCase()];
  if (typeof osPath === 'undefined') {
    throw new Error('Unsupported operating system');
  }

  let needChdir = 0;
  if (osPath == 'linux') {
    const files = fs.readdirSync('/lib').filter((fn) => fn.startsWith('libc.musl'));
    if (files.length > 0) {
      osPath = 'linux-musl';
      needChdir = 1;
    }
  }

  const archPath = {'arm64': 'arm64', 'x64': 'amd64'}[process.arch.toLowerCase()];
  if (typeof archPath === 'undefined') {
    throw new Error('Unsupported architecture');
  }

  libpath = path.resolve(path.join(libraryRootPath, osPath, archPath));

  ffi = require('ffi-napi');

  let oldCwd;
  if (needChdir == 1) {
    oldCwd = process.cwd();
    process.chdir(libpath);
  }

  libfile = path.join(libpath, 'libplugtest');

  libplugtest = new ffi.Library(libfile, {
    'calculatePi': ['int32', ['int32', 'char *', 'int32']],
    'sleepTest': ['void', ['int32']],
    'addInt32': ['int32', ['int32', 'int32']],
    'addInt64': ['int64', ['int64', 'int64']],
    'addDouble': ['double', ['double', 'double']],
  });

  libplugtestPointerInputs = new ffi.Library(libfile, {
    'toUpper': ['int32', ['char *', 'int32', 'char *', 'int32']],
  });

  libplugtestStringInputs = new ffi.Library(libfile, {
    'toUpper': ['int32', ['string', 'int32', 'char *', 'int32']],
  });

  if (needChdir == 1) {
    process.chdir(oldCwd);
  }
}

// ***********************************************************************************************************
// Pointer input declarations
// ***********************************************************************************************************

/**
* @param {string} str
* @return {string}
*/
function toUpperInGoPointerInputsCreateCString(str) {
  if (!initialized) {
    throw new Error('libplugtest was not initialized');
  }

  // Create null delimited C string
  const buf = Buffer.allocUnsafe(str.length + 1);
  buf.writeCString(str);

  // Must use buf.byteLength - 1 because of included null
  const result = libplugtestPointerInputs.toUpper(buf, buf.byteLength - 1, buf, buf.byteLength);
  if (result < 0) {
    throw new Error('toUpperMutableNullDelimited failed: ' + result);
  }

  return buf.toString('utf-8', 0, result);
}


/**
* @param {string} str
* @return {string}
*/
function toUpperInGoPointerInputsBufferFrom(str) {
  if (!initialized) {
    initializeLibPlugTest();
  }

  // Create length delimited buffer
  const buf = Buffer.from(str);

  const result = libplugtestPointerInputs.toUpper(buf, buf.byteLength, buf, buf.byteLength);
  if (result < 0) {
    throw new Error('toUpperMutableLengthDelimited failed: ' + result);
  }

  return buf.toString('utf-8', 0, result);
}

/**
* @param {string} str
* @return {string}
*/
function toUpperInGoPointerInputsBufferFromBufferAllocUnsafe(str) {
  if (!initialized) {
    initializeLibPlugTest();
  }

  // Create length delimited buffer
  const buf = Buffer.from(str);

  // Create output buffer
  const out = Buffer.allocUnsafe(buf.length + 1); // Pad this for demonstration purposes

  const result = libplugtestPointerInputs.toUpper(buf, buf.length, out, out.length);
  if (result < 0) {
    throw new Error('toUpperLengthDelimitedToOutputBuffer failed: ' + result);
  }

  return out.toString('utf-8', 0, result);
}

// ***********************************************************************************************************
// String input declarations
// ***********************************************************************************************************

/**
* @param {string} str
* @return {string}
*/
function toUpperInGoStringInputsCreateCString(str) {
  if (!initialized) {
    initializeLibPlugTest();
  }

  // Create null delimited C string
  const buf = Buffer.allocUnsafe(str.length + 1);
  buf.writeCString(str);

  const result = libplugtestStringInputs.toUpper(buf, buf.length - 1, buf, buf.length);
  if (result < 0) {
    throw new Error('toUpperMutableNullDelimited failed: ' + result);
  }

  return buf.toString('utf-8', 0, result);
}

/**
* @param {string} str
* @return {string}
*/
function toUpperInGoStringInputsBufferFrom(str) {
  if (!initialized) {
    initializeLibPlugTest();
  }

  // Create length delimited buffer
  const buf = Buffer.from(str);

  const result = libplugtestStringInputs.toUpper(buf, buf.length, buf, buf.length);
  if (result < 0) {
    throw new Error('toUpperMutableLengthDelimited failed: ' + result);
  }

  return buf.toString('utf-8', 0, result);
}

/**
* @param {string} str
* @return {string}
*/
function toUpperInGoStringInputsPassStringDirectlyBufferAllocUnsafe(str) {
  if (!initialized) {
    initializeLibPlugTest();
  }

  // Create output buffer
  const out = Buffer.allocUnsafe(str.length + 1); // Pad this for demonstration purposes

  const result = libplugtestStringInputs.toUpper(str, str.length, out, out.length);
  if (result < 0) {
    throw new Error('toUpperNullDelimitedToOutputBuffer failed: ' + result);
  }

  return out.toString('utf-8', 0, result);
}

/**
* @param {string} str
* @return {string}
*/
function toUpperInGoStringInputsBufferFromBufferAllocUnsafe(str) {
  if (!initialized) {
    initializeLibPlugTest();
  }

  // Create length delimited buffer
  const buf = Buffer.from(str);

  // Create output buffer
  const out = Buffer.allocUnsafe(buf.length + 1); // Pad this for demonstration purposes

  const result = libplugtestStringInputs.toUpper(buf, buf.length, out, out.length);
  if (result < 0) {
    throw new Error('toUpperLengthDelimitedToOutputBuffer failed: ' + result);
  }

  return out.toString('utf-8', 0, result);
}

// ***********************************************************************************************************
// Non-string functions
// ***********************************************************************************************************

/**
* @param {number} x
* @param {number} y
* @return {number}
*/
function addInt32InGo(x, y) {
  if (!initialized) {
    initializeLibPlugTest();
  }
  return libplugtest.addInt32(x, y);
}

/**
* @param {number} x
* @param {number} y
* @return {number}
*/
function addInt64InGo(x, y) {
  if (!initialized) {
    initializeLibPlugTest();
  }
  return libplugtest.addInt64(x, y);
}

/**
* @param {number} x
* @param {number} y
* @return {number}
*/
function addDoubleInGo(x, y) {
  if (!initialized) {
    initializeLibPlugTest();
  }
  return libplugtest.addDouble(x, y);
}

/**
* @param {number} seconds
* @return {Promise}
*/
function sleepInGo(seconds) {
  if (!initialized) {
    initializeLibPlugTest();
  }
  return new Promise((resolve) => {
    libplugtest.sleepTest.async(seconds, () => {
      resolve();
    });
  });
}

module.exports = {
  toUpperInGoPointerInputsCreateCString,
  toUpperInGoPointerInputsBufferFrom,
  toUpperInGoPointerInputsBufferFromBufferAllocUnsafe,
  toUpperInGoStringInputsCreateCString,
  toUpperInGoStringInputsBufferFrom,
  toUpperInGoStringInputsPassStringDirectlyBufferAllocUnsafe,
  toUpperInGoStringInputsBufferFromBufferAllocUnsafe,
  sleepInGo, addInt32InGo, addInt64InGo, addDoubleInGo};
