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
library_file_path = os.path.join(str(library_path), f"libplugtest.{ext}")

if need_chdir:
    old_dir = os.getcwd()
    os.chdir(library_path)

lib = ffi.dlopen(library_file_path)

if need_chdir:
    os.chdir(old_dir)

input_str = "Initial value"

cdata = ffi.from_buffer(input_str.encode("utf8"))

result = lib.toUpper(cdata, len(cdata), cdata, len(cdata))
if result < 0:
    raise Exception("toUpper failed")

output_str = ffi.unpack(cdata, result).decode("utf8")

print(output_str)
