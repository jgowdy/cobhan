
import { Library } from 'ffi-napi';
import { resolve, join } from 'path';

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
    load_platform_library,
};
