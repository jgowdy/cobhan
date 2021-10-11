/* eslint-disable max-len */
const path = require('path');
const library_loader = require('cobhanjs');

/**
* @param {object} input
* @param {string} disallowedValue
* @return {object}
*/
function filterJsonObjectInGo(input, disallowedValue) {
    let inputJson = JSON.stringify(input)
    const outputBuffer = Buffer.allocUnsafe(inputJson.length);

    const result = libplugtest.filterJson(inputJson, inputJson.length, disallowedValue, disallowedValue.length, outputBuffer, outputBuffer.length);
    if (result < 0) {
        throw new Error('filterJson failed: ' + result);
    }

    return JSON.parse(outputBuffer.toString('utf8', 0, result));
}

/**
* @param {string} inputJson
* @param {string} disallowedValue
* @return {string}
*/
function filterJsonStringInGo(inputJson, disallowedValue) {
    const outputBuffer = Buffer.allocUnsafe(inputJson.length);

    const result = libplugtest.filterJson(inputJson, inputJson.length, disallowedValue, disallowedValue.length, outputBuffer, outputBuffer.length);
    if (result < 0) {
        throw new Error('filterJson failed: ' + result);
    }

    return outputBuffer.toString('utf8', 0, result);
}

/**
* @param {string} input
* @return {string}
*/
function toUpperInGo(input) {
  const outputBuffer = Buffer.allocUnsafe(input.length);

  const result = libplugtest.toUpper(input, input.length, outputBuffer, outputBuffer.length);
  if (result < 0) {
    throw new Error('toUpper failed: ' + result);
  }

  return outputBuffer.toString('utf8', 0, result);
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
const libplugtest = library_loader.load_platform_library(libraryRootPath, 'libplugtest', {
    'sleepTest': ['void', ['int32']],
    'addInt32': ['int32', ['int32', 'int32']],
    'addInt64': ['int64', ['int64', 'int64']],
    'addDouble': ['double', ['double', 'double']],
    'toUpper': ['int32', ['string', 'int32', 'char *', 'int32']],
    'filterJson': ['int32', ['string', 'int32', 'string', 'int32', 'char *', 'int32']]
    });

module.exports = { filterJsonObjectInGo, filterJsonStringInGo, toUpperInGo, sleepInGo, addInt32InGo, addInt64InGo, addDoubleInGo };
