import os
import sys
from cobhan_demo.libcobhandemo import CobhanDemoLib

lib_file = sys.argv[1]

print(f"Testing: {lib_file}")

if os.path.isfile(lib_file):
    lib = CobhanDemoLib.from_library_file(str(os.path.abspath(lib_file)))
else:
    print("Library file is missing")
    sys.exit(255)

print(f"Loaded: {lib_file}")

result = lib.to_upper('Initial value')
if result != "INITIAL VALUE":
    print("to_upper test failed")
    sys.exit(255)

result2 = lib.add_int32(1, 1)
if result2 != 2:
    print("add_int32 test failed")
    sys.exit(255)

result3 = lib.base64Encode("Test")
if result3 != "VGVzdA==":
    print("base64Encode test failed")
    sys.exit(255)

result4 = lib.filterJson({'test': 'foo', 'test2': 'kittens'}, 'foo')
if result4["test2"] != "kittens":
    print("filterJson test failed")
    sys.exit(255)

print(f"Passed: {lib_file}")
