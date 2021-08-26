require 'ffi'

# https://github.com/ffi/ffi/blob/master/lib/ffi/platform.rb
OS_PATH =
  case FFI::Platform::OS
  when 'linux'
    'linux'
  when 'darwin'
    'macos'
  when 'windows'
    'windows'
  else
    raise 'Unsupported operating system'
  end

CPU_ARCH =
  case FFI::Platform::ARCH
  when 'x86_64'
    'amd64'
  when 'aarch64'
    'arm64'
  else
    raise 'Unsupported CPU'
  end

EXT = RbConfig::CONFIG['DLEXT']

module MyLib
  extend FFI::Library
  ffi_lib File.join(File.dirname(__FILE__), "../output/#{OS_PATH}/#{CPU_ARCH}/libplugtest.#{EXT}")

  attach_function :toUpper, [ :string ], :void
end

input = 'Initial value'
MyLib.toUpper(input)
p input # "INITIAL VALUE"
