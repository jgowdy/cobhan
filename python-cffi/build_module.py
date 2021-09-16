import platform
from cffi import FFI
ffibuilder = FFI()

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

# set_source() gives the name of the python extension module to
# produce, and some C source code as a string.  This C code needs
# to make the declarated functions, types and globals available,
# so it is often just the "#include".
ffibuilder.set_source("_cobhan_cffi","#include \"../output/" + os_path + "/" + cpu_arch + "/libplugtest.h\"",
     libraries=["libplugtest." + ext])   # library name, for the linker

if __name__ == "__main__":
    ffibuilder.compile(verbose=True)