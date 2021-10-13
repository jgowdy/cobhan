
import pathlib
import platform
import os
import json

from cffi import FFI

class Cobhan():
    def __init__(self):
        self.__ffi = FFI()

    def _load_library(self, library_root_path, library_name, cdefines):
        self.__ffi.cdef(cdefines)

        system = platform.system()
        need_chdir = 0
        if system == "Linux":
            if pathlib.Path("/lib").match("libc.musl*"):
                os_path = "linux-musl"
                need_chdir = 1
            else:
                os_path = "linux"
            ext = "so"
        elif system == "Darwin":
            os_path = "macos"
            ext = "dylib"
        elif system == "Windows":
            os_path = "windows"
            ext = "dll"
        else:
            raise Exception("Unsupported operating system")

        machine = platform.machine()
        if machine == "x86_64" or machine == "AMD64":
            cpu_arch = "amd64"
        elif machine == "arm64":
            cpu_arch = "arm64"
        else:
            raise Exception("Unsupported CPU")

        # Get absolute library path
        library_path = pathlib.Path(os.path.join(library_root_path, os_path, cpu_arch)).resolve()

        # Build library path with file name
        library_file_path = os.path.join(str(library_path), f"{library_name}.{ext}")

        if need_chdir:
            old_dir = os.getcwd()
            os.chdir(library_path)

        self._lib = self.__ffi.dlopen(library_file_path)

        if need_chdir:
            os.chdir(old_dir)

    def _load_library_direct(self, library_file_path, cdefines):
        self.__ffi.cdef(cdefines)
        self._lib = self.__ffi.dlopen(library_file_path)

    def to_json_buf(self, obj):
        return self.str_to_buf(json.dumps(obj))

    def from_json_buf(self, buf, length):
        return json.loads(self.buf_to_str(buf, length))

    def str_to_buf(self, string):
        return self.__ffi.from_buffer(string.encode("utf8"))

    def buf_to_str(self, buf, len):
        return self.__ffi.unpack(buf, len).decode("utf8")

    def allocate_buf(self, len):
        return self.__ffi.new(f'char[{len}]')
