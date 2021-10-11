
const ffi = require('ffi-napi');
const path = require('path');

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

    let libpath = path.resolve(path.join(libraryRootPath, osPath, archPath));

    let oldCwd;
    if (needChdir) {
        oldCwd = process.cwd();
        process.chdir(libpath);
    }

    let libfile = path.join(libpath, libraryName);

    let library = new ffi.Library(libfile, functions);

    if (needChdir) {
        process.chdir(oldCwd);
    }

    return library
  }

  module.exports = {
    load_platform_library,
};
