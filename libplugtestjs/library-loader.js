
const ffi = require('ffi-napi');

// This code is reused between wrappers

/**
* @param {string} libraryRootPath
* @param {object} functions
* @return {any}
*/
function load_platform_library(libraryRootPath, functions) {
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

    let oldCwd;
    if (needChdir == 1) {
        oldCwd = process.cwd();
        process.chdir(libpath);
    }

    libfile = path.join(libpath, 'libplugtest');

    let library = new ffi.Library(libfile, functions);

    if (needChdir == 1) {
    process.chdir(oldCwd);
    }

    return library
  }

  module.exports = {
    load_platform_library,
};
