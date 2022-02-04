from io import UnsupportedOperation
import pathlib
import platform
import os
import json

from cffi import FFI

class Cobhan():

    def __init__(self):
        self.__ffi = FFI()
        self.__sizeof_int32 = self.__ffi.sizeof("int32_t")
        self.__sizeof_header = self.__sizeof_int32 * 2
        self.__minimum_allocation = 1024
        self.__int32_zero_bytes = int(0).to_bytes(self.__sizeof_int32, byteorder='little', signed=True)

    def _load_library(self, library_path, library_name, cdefines):
        self.__ffi.cdef(cdefines)

        system = platform.system()
        need_chdir = 0
        if system == "Linux":
            if pathlib.Path("/lib").match("libc.musl*"):
                os_ext = "-musl.so"
                need_chdir = 1
            else:
                os_path = ".so"
        elif system == "Darwin":
            os_ext = ".dylib"
        elif system == "Windows":
            os_ext = ".dll"
        else:
            raise UnsupportedOperation("Unsupported operating system")

        machine = platform.machine()
        if machine == "x86_64" or machine == "AMD64":
            arch_part = "-x64"
        elif machine == "arm64":
            arch_part = "-arm64"
        else:
            raise UnsupportedOperation("Unsupported CPU")

        # Get absolute library path
        resolved_library_path = pathlib.Path(os.path.join(library_path, os_path, cpu_arch)).resolve()

        # Build library path with file name
        library_file_path = os.path.join(str(resolved_library_path), f"{library_name}{arch_part}{os_ext}")

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

    def from_json_buf(self, buf):
        return json.loads(self.buf_to_str(buf))

    def set_header(self, buf, length):
        self.__ffi.memmove(buf[0:self.__sizeof_int32],
                           length.to_bytes(self.__sizeof_int32, byteorder='little', signed=True), self.__sizeof_int32)
        self.__ffi.memmove(buf[self.__sizeof_int32:self.__sizeof_int32 * 2],
                           self.__int32_zero_bytes, self.__sizeof_int32)

    def set_payload(self, buf, payload, length):
        self.set_header(buf, length)
        self.__ffi.memmove(buf[self.__sizeof_header:self.__sizeof_header + length - 1], payload, length)

    def bytearray_to_buf(self, payload):
        length = len(payload)
        buf = self.allocate_buf(length)
        self.set_payload(buf, payload, length)
        return buf

    def str_to_buf(self, string):
        encoded_bytes = string.encode("utf8")
        length = len(encoded_bytes)
        buf = self.allocate_buf(length)
        self.set_payload(buf, encoded_bytes, length)
        return buf

    def allocate_buf(self, buffer_len):
        length = int(buffer_len)
        length = max(length, self.__minimum_allocation)
        buf = self.__ffi.new(f'char[{self.__sizeof_header + length}]')
        self.set_header(buf, length)
        return buf

    def buf_to_str(self, buf):
        length_buf = self.__ffi.unpack(buf, self.__sizeof_int32)
        length = int.from_bytes(length_buf, byteorder='little', signed=True)
        if length < 0:
            return self.temp_to_str(buf, length)
        encoded_bytes = self.__ffi.unpack(buf[self.__sizeof_header:self.__sizeof_header + length], length)
        return encoded_bytes.decode("utf8")

    def buf_to_bytearray(self, buf):
        length_buf = self.__ffi.unpack(buf, self.__sizeof_int32)
        length = int.from_bytes(length_buf, byteorder='little', signed=True)
        if length < 0:
            return self.temp_to_bytearray(buf, length)
        payload = bytearray(length)
        self.__ffi.memmove(payload, buf[self.__sizeof_header:self.__sizeof_header + length], length)
        return payload

    def temp_to_str(self, buf, length):
        encoded_bytes = self.temp_to_bytearray(buf, length)
        return encoded_bytes.decode("utf8")

    def temp_to_bytearray(self, buf, length):
        length = 0 - length
        encoded_bytes = self.__ffi.unpack(buf[self.__sizeof_header:self.__sizeof_header + length], length)
        file_name = encoded_bytes.decode("utf8")
        with open(file_name, "rb") as binaryfile:
            payload = bytearray(binaryfile.read())
        os.remove(file_name)
        return payload
