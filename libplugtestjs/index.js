/* eslint-disable max-len */
const path = require('path');
const library_loader = require('load-platform-library');

let libplugtest;

function filterJsonInGo(inputJson, disallowedValue) {
    // Create output buffer
    const out = Buffer.allocUnsafe(str.length);

    const result = libplugtest.filterJson(inputJson, inputJson.length, disallowedValue, disallowedValue.length, out, out.length);
    if (result < 0) {
        throw new Error('filterJson failed: ' + result);
    }

    return out.toString('utf8', 0, result);
}

/**
* @param {string} str
* @return {string}
*/
function toUpperInGo(str) {
  // Create output buffer
  const out = Buffer.allocUnsafe(str.length);

  const result = libplugtest.toUpper(str, str.length, out, out.length);
  if (result < 0) {
    throw new Error('toUpper failed: ' + result);
  }

  return out.toString('utf8', 0, result);
}

/**
* @param {number} x
* @param {number} y
* @return {number}
*/
function addInt32InGo(x, y) {
  return libplugtest.addInt32(x, y);
}

/**
* @param {number} x
* @param {number} y
* @return {number}
*/
function addInt64InGo(x, y) {
  return libplugtest.addInt64(x, y);
}

/**
* @param {number} x
* @param {number} y
* @return {number}
*/
function addDoubleInGo(x, y) {
  return libplugtest.addDouble(x, y);
}

/**
* @param {number} seconds
* @return {Promise}
*/
function sleepInGo(seconds) {
  return new Promise((resolve) => {
    libplugtest.sleepTest.async(seconds, () => {
      resolve();
    });
  });
}

// Provide the base path of the library binaries
const libraryRootPath = path.join(__dirname, 'libplugtest-binaries');

// Provide the function declarations we are importing
libplugtest = library_loader.load_platform_library(libraryRootPath, {
    'calculatePi': ['int32', ['int32', 'char *', 'int32']],
    'sleepTest': ['void', ['int32']],
    'addInt32': ['int32', ['int32', 'int32']],
    'addInt64': ['int64', ['int64', 'int64']],
    'addDouble': ['double', ['double', 'double']],
    'toUpper': ['int32', ['string', 'int32', 'char *', 'int32']],
    'filterJson': ['int32', ['string', 'int32', 'string', 'int32', 'char *', 'int32']]
    });

module.exports = { toUpperInGo, sleepInGo, addInt32InGo, addInt64InGo, addDoubleInGo };
