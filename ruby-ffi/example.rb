require 'ffi'

UnsupportedPlatformError = Class.new(StandardError)

OS_PATHS = { 'linux' => 'linux', 'darwin' => 'macos', 'windows' => 'windows' }.freeze
os_path = OS_PATHS[FFI::Platform::OS]
raise UnsupportedPlatformError, "Unsupported operating system: #{FFI::Platform::OS}" unless OS_PATH

if os_path == 'linux'
    Dir.children("/lib")
    if Dir.glob("/lib/libc.musl*").length
        os_path = 'linux-musl'
    end
end

EXTS = { 'linux' => 'so', 'darwin' => 'dylib', 'windows' => 'dll'}.freeze
EXT = EXTS[FFI::Platform::OS]

CPU_ARCHS = { 'x86_64' => 'amd64', 'aarch64' => 'arm64' }.freeze
CPU_ARCH = CPU_ARCHS[FFI::Platform::ARCH]
raise UnsupportedPlatformError, "Unsupported CPU: #{FFI::Platform::CPU_ARCH}" unless CPU_ARCH

module MyLib
  extend FFI::Library
  lib_path = "../output/#{os_path}/#{CPU_ARCH}/"
  puts "Using path #{lib_path}"
  old_dir = Dir.pwd
  puts "Saving old directory #{old_dir}"
  Dir.chdir(lib_path)
  ffi_lib File.join(File.dirname(__FILE__), "#{lib_path}/libplugtest.#{EXT}")
  Dir.chdir(old_dir)

  attach_function :calculatePi, [ :int32, :pointer, :int32 ], :int32
  attach_function :sleepTest, [ :int32 ], :void
  attach_function :addInt32, [:int32, :int32], :int32
  attach_function :addInt64, [:int64, :int64], :int64
  attach_function :addDouble, [:double, :double], :double

  attach_function :toUpper, [:pointer, :int32, :pointer, :int32], :int32
end

def calculatePi(digits)
    piBuffer = FFI::MemoryPointer.new(1, digits + 1, false)

    result = MyLib.calculatePi(digits, piBuffer, piBuffer.size)
    if result < 0
        raise 'Failed to calculate pi'
    end

    piBuffer.get_string(0, result)
end

def toUpper(input)
    in_ptr = FFI::MemoryPointer.from_string(input)
    out_ptr = FFI::MemoryPointer.new(1, in_ptr.size + 1, false)

    result = MyLib.toUpper(in_ptr, in_ptr.size, out_ptr, out_ptr.size)
    if result < 0
        raise 'Failed to convert toUpper'
    end

    out_ptr.get_string(0, result)
end

def sleepTest(seconds)
    MyLib.sleepTest(seconds)
end

def addInt32(x, y)
    MyLib.addInt32(x, y)
end

def addInt64(x, y)
    MyLib.addInt64(x, y)
end

def addDouble(x, y)
    MyLib.addDouble(x, y)
end

puts calculatePi(100)
puts addInt32(10, 10)
puts addInt64(20, 20)
puts addDouble(1.2, 2.3)
puts toUpper('Initial value')
