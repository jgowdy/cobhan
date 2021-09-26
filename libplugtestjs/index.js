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

  const library_root_path = path.join(__dirname, 'libplugtest-binaries');

  let os_path = {'win32': 'windows', 'linux': 'linux', 'darwin': 'macos'}[process.platform.toLowerCase()];
  if (typeof os_path === 'undefined') {
    throw 'Unsupported operating system';
  }

  let need_chdir = 0;
  if (os_path == 'linux') {
    const files = fs.readdirSync('/lib').filter((fn) => fn.startsWith('libc.musl'));
    if (files.length > 0) {
      os_path = 'linux-musl';
      need_chdir = 1;
    }
  }

  const arch_path = {'arm64': 'arm64', 'x64': 'amd64'}[process.arch.toLowerCase()];
  if (typeof arch_path === 'undefined') {
    throw 'Unsupported architecture';
  }

  libpath = path.resolve(path.join(library_root_path, os_path, arch_path));

  ffi = require('ffi-napi');

  let old_cwd;
  if (need_chdir == 1) {
    old_cwd = process.cwd();
    process.chdir(libpath);
  }

  libfile = path.join(libpath, 'libplugtest');

  libplugtest = ffi.Library(libfile, {
    'calculatePi': ['int32', ['int32', 'char *', 'int32']],
    'sleepTest': ['void', ['int32']],
    'addInt32': ['int32', ['int32', 'int32']],
    'addInt64': ['int64', ['int64', 'int64']],
    'addDouble': ['double', ['double', 'double']],
  });

  libplugtestPointerInputs = ffi.Library(libfile, {
    'toUpper': ['int32', ['char *', 'int32', 'char *', 'int32']],
  });

  libplugtestStringInputs = ffi.Library(libfile, {
    'toUpper': ['int32', ['string', 'int32', 'char *', 'int32']],
  });

  if (need_chdir == 1) {
    process.chdir(old_cwd);
  }
}

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
  const buf = Buffer.allocUnsafe(str.length + 1);
  buf.writeCString(str);

  // Must use buf.byteLength - 1 because of included null
  const result = libplugtestPointerInputs.toUpper(buf, buf.byteLength - 1, buf, buf.byteLength);
  if (result < 0) {
    throw 'toUpperMutableNullDelimited failed: ' + result;
  }

  return buf.toString('utf-8', 0, result);
}


/**
* @param {string} str
*/
function toUpperInGoPointerInputsBufferFrom(str) {
  if (!initialized) {
    initializeLibPlugTest();
  }

  // Create length delimited buffer
  const buf = Buffer.from(str);

  const result = libplugtestPointerInputs.toUpper(buf, buf.byteLength, buf, buf.byteLength);
  if (result < 0) {
    throw 'toUpperMutableLengthDelimited failed: ' + result;
  }

  return buf.toString('utf-8', 0, result);
}

/**
* @param {string} str
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
    throw 'toUpperLengthDelimitedToOutputBuffer failed: ' + result;
  }

  return out.toString('utf-8', 0, result);
}

// ***********************************************************************************************************
// String input declarations
// ***********************************************************************************************************

/**
* @param {string} str
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
    throw 'toUpperMutableNullDelimited failed: ' + result;
  }

  return buf.toString('utf-8', 0, result);
}

/**
* @param {string} str
*/
function toUpperInGoStringInputsBufferFrom(str) {
  if (!initialized) {
    initializeLibPlugTest();
  }

  // Create length delimited buffer
  const buf = Buffer.from(str);

  const result = libplugtestStringInputs.toUpper(buf, buf.length, buf, buf.length);
  if (result < 0) {
    throw 'toUpperMutableLengthDelimited failed: ' + result;
  }

  return buf.toString('utf-8', 0, result);
}

/**
* @param {string} str
*/
function toUpperInGoStringInputsPassStringDirectlyBufferAllocUnsafe(str) {
  if (!initialized) {
    initializeLibPlugTest();
  }

  // Create output buffer
  const out = Buffer.allocUnsafe(str.length + 1); // Pad this for demonstration purposes

  const result = libplugtestStringInputs.toUpper(str, str.length, out, out.length);
  if (result < 0) {
    throw 'toUpperNullDelimitedToOutputBuffer failed: ' + result;
  }

  return out.toString('utf-8', 0, result);
}

/**
* @param {string} str
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
    throw 'toUpperLengthDelimitedToOutputBuffer failed: ' + result;
  }

  return out.toString('utf-8', 0, result);
}

// ***********************************************************************************************************
// Non-string functions
// ***********************************************************************************************************

/**
* @param {number} x
* @param {number} y
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
*/
function addDoubleInGo(x, y) {
  if (!initialized) {
    initializeLibPlugTest();
  }
  return libplugtest.addDouble(x, y);
}

/**
* @param {number} seconds
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
