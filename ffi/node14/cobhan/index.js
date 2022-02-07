import ffi from 'ffi-napi'
import path from 'path'

const header_size = 64 / 8
const sizeof_int32 = 32 / 8
/**
* @param {string} str
* @return {Buffer}
*/
function string_to_cbuffer(str) {
    // string.length returns number of two byte UTF-16 code units
    let buffer = Buffer.allocUnsafe(header_size + str.length * 2)
    buffer.writeInt32LE(str.length, 0)
    buffer.writeInt32LE(0, sizeof_int32) // Reserved - must be zero
    buffer.write(str, header_size, 'utf8')
    return buffer
}

function int64_to_buffer(number) {
    let buffer = Buffer.allocUnsafe(64 / 8)
    buffer.writeBigInt64LE(BigInt(number), 0)
    return buffer
}

function buffer_to_int64(buffer) {
    return buffer.readInt64LE(0)
}

/**
* @param {Buffer} buf
* @return {string}
*/
function cbuffer_to_string(buf) {
    let length = buf.readInt32LE(0)
    if (length < 0) {
        return temp_to_string(buf, length)
    }
    console.log('cbuffer_to_string: got ' + length + ' bytes')
    return buf.toString('utf8', header_size, length + header_size)
}

/**
* @param {Buffer} buf
* @param {Number} length
* @return {string}
*/
function temp_to_string(buf, length) {
    length = 0 - length
    tempfile = buf.toString('utf8', header_size, length + header_size)
    result = fs.readFileSync(tempfile, 'utf8')
    fs.unlinkSync(tempfile)
    return result
}

/**
* @param {Buffer} buf
* @return {Buffer}
*/
function cbuffer_to_buffer(buf) {
    let length = buf.readInt32LE(0)
    if (length < 0) {
        return temp_to_buffer(buf, length)
    }
    return buf.slice(header_size, header_size + length)
}

/**
* @param {Buffer} buf
* @param {Number} length
* @return {Buffer}
*/
function temp_to_buffer(buf, length) {
    length = 0 - length
    tempfile = buf.toString('utf8', header_size, length + header_size)
    result = fs.readFileSync(tempfile)
    fs.unlinkSync(tempfile)
    return result
}

/**
* @param {Buffer} buf
* @return {Buffer}
*/
function buffer_to_cbuffer(buf) {
    let buffer = Buffer.allocUnsafe(header_size + buf.byteLength)
    buffer.writeInt32LE(buf.byteLength, 0)
    buffer.writeInt32LE(0, sizeof_int32) // Reserved - must be zero
    buffer.fill(buf, header_size)
    return buffer
}

/**
* @param {number} size
* @return {Buffer}
*/
function allocate_cbuffer(size) {
    let buffer = Buffer.allocUnsafe(header_size + size)
    buffer.writeInt32LE(size, 0)
    buffer.writeInt32LE(0, sizeof_int32) // Reserved - must be zero
    return buffer
}

/*
  libcobhandemo-arm64.dylib
  libcobhandemo-x64.dylib
  libcobhandemo-x64.so
  libcobhandemo-x64-musl.so
  libcobhandemo-arm64-musl.so
  libcobhandemo-x64.dll
 */

/**
* @param {string} libraryRootPath
* @param {string} libraryName
* @param {object} functions
* @return {any}
*/
function load_platform_library(libraryPath, libraryName, functions) {

    let osExt = {'win32': '.dll', 'linux': '.so', 'darwin': '.dylib'}[process.platform.toLowerCase()];
    if (typeof osExt === 'undefined') {
        throw new Error('Unsupported operating system');
    }

    let needChdir = false;
    if (osExt == 'linux') {
        const files = fs.readdirSync('/lib').filter((fn) => fn.startsWith('libc.musl'));
        if (files.length > 0) {
            osExt = '-musl' + osExt;
            needChdir = true;
        }
    }

    const archPart = {'arm64': '-arm64', 'x64': '-x64'}[process.arch.toLowerCase()];
    if (typeof archPart === 'undefined') {
        throw new Error('Unsupported architecture');
    }

    let libraryFile = path.resolve(path.join(libraryPath, libraryName + archPart + osExt));

    let oldCwd;
    if (needChdir) {
        oldCwd = process.cwd();
        process.chdir(libraryPath);
    }

    let library = new ffi.Library(libraryFile, functions);

    if (needChdir) {
        process.chdir(oldCwd);
    }

    return library
  }

/**
* @param {string} libraryFilePath
* @param {object} functions
* @return {any}
*/
function load_library_direct(libraryFilePath, functions) {
    let library = new ffi.Library(libraryFilePath, functions);
    return library
  }

  export default {
    load_platform_library, string_to_cbuffer, cbuffer_to_string, cbuffer_to_buffer, buffer_to_cbuffer, allocate_cbuffer, int64_to_buffer, buffer_to_int64, load_library_direct
};
