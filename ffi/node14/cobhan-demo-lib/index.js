import { join } from 'path';
import { load_platform_library, string_to_cbuffer, cbuffer_to_string, cbuffer_to_buffer, buffer_to_cbuffer, allocate_cbuffer } from 'cobhan';

/**
* @param {object} input
* @param {string} disallowedValue
* @return {object}
*/
function filterJsonObjectInGo(input, disallowedValue) {
    const inputBuffer = string_to_cbuffer(JSON.stringify(input));
    const disallowedBuffer = string_to_cbuffer(disallowedValue);
    const outputBuffer = allocate_cbuffer(input.length);

    const result = cobhanDemoLib.filterJson(inputBuffer, disallowedBuffer, outputBuffer);
    if (result < 0) {
        throw new Error('filterJson failed: ' + result);
    }

    return JSON.parse(cbuffer_to_string(outputBuffer));
}

/**
* @param {string} inputJson
* @param {string} disallowedValue
* @return {string}
*/
function filterJsonStringInGo(inputJson, disallowedValue) {
    const inputBuffer = string_to_cbuffer(inputJson);
    const disallowedBuffer = string_to_cbuffer(disallowedValue);
    const outputBuffer = allocate_cbuffer(inputJson.length);

    const result = cobhanDemoLib.filterJson(inputBuffer, disallowedBuffer, outputBuffer);
    if (result < 0) {
        throw new Error('filterJson failed: ' + result);
    }

    return cbuffer_to_string(outputBuffer);
}

/**
* @param {string} input
* @return {string}
*/
function toUpperInGo(input) {
    const inputBuffer = string_to_cbuffer(input);
    const outputBuffer = allocate_cbuffer(input.length);

  const result = cobhanDemoLib.toUpper(inputBuffer, outputBuffer);
  if (result < 0) {
    throw new Error('toUpper failed: ' + result);
  }

  return cbuffer_to_string(outputBuffer);
}

/**
* @param {number} x
* @param {number} y
* @return {number}
*/
function addInt32InGo(x, y) {
  return cobhanDemoLib.addInt32(x, y);
}

/**
* @param {number} x
* @param {number} y
* @return {number}
*/
function addInt64InGo(x, y) {
  return cobhanDemoLib.addInt64(x, y);
}

/**
* @param {number} x
* @param {number} y
* @return {number}
*/
function addDoubleInGo(x, y) {
  return cobhanDemoLib.addDouble(x, y);
}

/**
* @param {number} seconds
* @return {Promise}
*/
function sleepInGo(seconds) {
  return new Promise((resolve) => {
    cobhanDemoLib.sleepTest.async(seconds, () => {
    resolve();
    });
  });
}

// Provide the base path of the library binaries
const libraryRootPath = join(__dirname, 'binaries');

// Provide the function declarations we are importing
const cobhanDemoLib = load_platform_library(libraryRootPath, 'cobhanDemoLib', {
    'sleepTest': ['void', ['int32']],
    'addInt32': ['int32', ['int32', 'int32']],
    'addInt64': ['int64', ['int64', 'int64']],
    'addDouble': ['double', ['double', 'double']],
    'toUpper': ['int32', ['pointer', 'pointer']],
    'filterJson': ['int32', ['pointer', 'pointer', 'pointer']]
    });

export default { filterJsonObjectInGo, filterJsonStringInGo, toUpperInGo, sleepInGo, addInt32InGo, addInt64InGo, addDoubleInGo };
