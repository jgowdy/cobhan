import os
from cobhan_demo_lib import CobhanDemoLib

if os.path.isfile('target/debug/cobhan-demo-lib.dylib'):
    library_file_name = 'target/debug/cobhan-demo-lib.dylib'
    lib = CobhanDemoLib.from_library_file(str(os.path.abspath(library_file_name)))
else:
    library_root_path = str(os.path.abspath(os.path.join(os.path.dirname(__file__),"../output")))
    lib = CobhanDemoLib.from_library_path(library_root_path)

print(lib.to_upper('Initial value'))

print(lib.add_int32(1, 1))

print(lib.base64Encode("Test"))

output = lib.filterJson({'test': 'foo', 'test2': 'kittens'}, 'foo')
print(output)
