import os
import sys
from libcobhandemo import CobhanDemoLib

lib_file = sys.argv[1]

if os.path.isfile(lib_file):
    lib = CobhanDemoLib.from_library_file(str(os.path.abspath(lib_file)))
else:
    sys.exit(255)

print(f"Testing: {lib_file}")

print(lib.to_upper('Initial value'))

print(lib.add_int32(1, 1))

print(lib.base64Encode("Test"))

output = lib.filterJson({'test': 'foo', 'test2': 'kittens'}, 'foo')
print(output)
