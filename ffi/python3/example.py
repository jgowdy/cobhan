import os
from libplugtest import Libplugtest

library_root_path = str(os.path.abspath(os.path.join(os.path.dirname(__file__),"../output")))
#library_root_path = 'target/debug/libplugtest.dylib'
#lib = Libplugtest.from_library_file(str(os.path.abspath(library_root_path)))

print(lib.to_upper('Initial value'))

print(lib.add_int32(1, 1))

print(lib.base64Encode("Test"))

output = lib.filterJson({'test': 'foo', 'test2': 'kittens'}, 'foo')
print(output)
