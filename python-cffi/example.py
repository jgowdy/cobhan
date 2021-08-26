import platform
from cffi import FFI
ffi = FFI()
ffi.cdef("""
   void toUpper(char *input);
""")

system = platform.system()
if system == "Linux":
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

lib = ffi.dlopen("../output/" + os_path + "/" + cpu_arch + "/libplugtest." + ext)

input = 'Initial value'

input_bytes = bytearray(input, 'utf8')
lib.toUpper(ffi.from_buffer(input_bytes))

print(input_bytes.decode())