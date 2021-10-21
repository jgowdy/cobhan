import { Library } from 'ffi-napi';
import { resolve, join } from 'path';

//TODO: Create Cobhan buffer class / function that is initialized with strings and returns strings

const header_size = 64 / 8

/**
* @param {string} str
* @return {Buffer}
*/
function string_to_cbuffer(str) {
    let buffer = Buffer.allocUnsafe(header_size + str.length)
    buffer.writeInt32LE(str.length, 0)
    buffer.write(str, header_size, 'utf8')
    return buffer
}

/**
* @param {Buffer} buf
* @return {string}
*/
function cbuffer_to_string(buf) {
    let length = buf.readInt32LE(0)
    return buf.toString('utf8', header_size, length)
}

/**
* @param {Buffer} buf
* @return {Buffer}
*/
function cbuffer_to_buffer(buf) {
    return buf.slice(header_size)
}

/**
* @param {Buffer} buf
* @return {Buffer}
*/
function buffer_to_cbuffer(buf) {
    let buffer = Buffer.allocUnsafe(header_size + buf.byteLength)
    buffer.writeInt32LE(buf.byteLength, 0)
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
    return buffer
}

/**
* @param {string} libraryRootPath
* @param {string} libraryName
* @param {object} functions
* @return {any}
*/
function load_platform_library(libraryRootPath, libraryName, functions) {
    let osPath = {'win32': 'windows', 'linux': 'linux', 'darwin': 'macos'}[process.platform.toLowerCase()];
    if (typeof osPath === 'undefined') {
        throw new Error('Unsupported operating system');
    }

    let needChdir = false;
    if (osPath == 'linux') {
        const files = fs.readdirSync('/lib').filter((fn) => fn.startsWith('libc.musl'));
        if (files.length > 0) {
            osPath = 'linux-musl';
            needChdir = true;
        }
    }

    const archPath = {'arm64': 'arm64', 'x64': 'amd64'}[process.arch.toLowerCase()];
    if (typeof archPath === 'undefined') {
        throw new Error('Unsupported architecture');
    }

    let libpath = resolve(join(libraryRootPath, osPath, archPath));

    let oldCwd;
    if (needChdir) {
        oldCwd = process.cwd();
        process.chdir(libpath);
    }

    let libfile = join(libpath, libraryName);

    let library = new Library(libfile, functions);

    if (needChdir) {
        process.chdir(oldCwd);
    }

    return library
  }

  export default {
    load_platform_library, string_to_cbuffer, cbuffer_to_string, cbuffer_to_buffer, buffer_to_cbuffer, allocate_cbuffer
};
