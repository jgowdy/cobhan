# frozen_string_literal: true

require 'ffi'

UnsupportedPlatformError = Class.new(StandardError)

LIBRARY_ROOT_PATH = '../output/'

if FFI::Platform::OS == 'linux' && Dir.glob('/lib/libc.musl*').length.positive?
  OS_PATH = 'linux-musl'
  NEED_CHDIR = 1
else
  OS_PATHS = { 'linux' => 'linux', 'darwin' => 'macos', 'windows' => 'windows' }.freeze
  OS_PATH = OS_PATHS[FFI::Platform::OS]
  NEED_CHDIR = 0
  raise UnsupportedPlatformError, "Unsupported operating system: #{FFI::Platform::OS}" unless OS_PATH
end

EXTS = { 'linux' => 'so', 'darwin' => 'dylib', 'windows' => 'dll' }.freeze
EXT = EXTS[FFI::Platform::OS]

CPU_ARCHS = { 'x86_64' => 'amd64', 'aarch64' => 'arm64' }.freeze
CPU_ARCH = CPU_ARCHS[FFI::Platform::ARCH]
raise UnsupportedPlatformError, "Unsupported CPU: #{FFI::Platform::CPU_ARCH}" unless CPU_ARCH

LIB_PATH = File.expand_path(File.join(LIBRARY_ROOT_PATH, OS_PATH, CPU_ARCH))

module MyLib
  extend FFI::Library
  
  if NEED_CHDIR == 1
    # Save current directory
    old_dir = Dir.pwd

    # Switch to library directory
    Dir.chdir(LIB_PATH)
  end

  # NOTE: Absolute path is required here
  ffi_lib File.join(LIB_PATH, "libplugtest.#{EXT}")

  if NEED_CHDIR == 1
    # Restore directory
    Dir.chdir(old_dir)
  end

  attach_function :calculatePi, %i[int32 pointer int32], :int32
  attach_function :sleepTest, [:int32], :void
  attach_function :addInt32, %i[int32 int32], :int32
  attach_function :addInt64, %i[int64 int64], :int64
  attach_function :addDouble, %i[double double], :double

  attach_function :toUpper, %i[pointer int32 pointer int32], :int32
end

def calculate_pi(digits)
  pi_buffer = FFI::MemoryPointer.new(1, digits + 1, false)

  result = MyLib.calculatePi(digits, pi_buffer, pi_buffer.size)
  raise 'Failed to calculate pi' if result.negative?

  pi_buffer.get_string(0, result)
end

def to_upper(input)
  in_ptr = FFI::MemoryPointer.from_string(input)
  out_ptr = FFI::MemoryPointer.new(1, in_ptr.size + 1, false)

  result = MyLib.toUpper(input, input.length, out_ptr, out_ptr.size)
  raise 'Failed to convert toUpper' if result.negative?

  out_ptr.get_string(0, result)
end

def sleep_test(seconds)
  MyLib.sleepTest(seconds)
end

def add_int32(x, y)
  MyLib.addInt32(x, y)
end

def add_int64(x, y)
  MyLib.addInt64(x, y)
end

def add_double(x, y)
  MyLib.addDouble(x, y)
end

puts calculate_pi(100)
puts add_int32(10, 10)
puts add_int64(20, 20)
puts add_double(1.2, 2.3)
puts to_upper('Initial value')
