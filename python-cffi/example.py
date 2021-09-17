import pathlib
import platform
import os

from cffi import FFI
ffi = FFI()

ffi.cdef("""
   void sleepTest(int32_t seconds);
   int32_t addInt32(int32_t x, int32_t y);
   int64_t addInt64(int64_t x, int64_t y);
   double addDouble(double x, double y);
   int32_t toUpper(const char *input, int32_t inputLength, char *output, int32_t outputCapacity);
   int32_t calculatePi(int32_t digits, char *output, int32_t outputCapacity);
""")

library_root_path = "../output/"

system = platform.system()
if system == "Linux":
    # Check for /lib/libc.musl* so we can set the need_chdir flag
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

# Supposedly more reliable than bits = architecture()[0] == '64bit'
# is_64bits = sys.maxsize > 2**32

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
library_file_path = os.path.join(str(library_path), "libplugtest." + ext)

# TODO: chdir if musl

lib = ffi.dlopen(library_file_path)

# TODO: restore directory

input_str = 'Initial value'

input_bytes = bytearray(input_str, 'utf8')
cdata = ffi.from_buffer(input_bytes)

result = lib.toUpper(cdata, len(input_bytes), cdata, len(input_bytes))
if result < 0:
    raise Exception('toUpper failed')

output_str = ffi.unpack(cdata, result).decode('utf8')

print("Output: " + output_str)
print(type(output_str))
