# frozen_string_literal: true

require 'ffi'
require 'IO'

module Cobhan
  UnsupportedPlatformError = Class.new(StandardError)

  module CobhanFFI
    extend FFI::Library

    OS_PATHS   = { 'linux' => 'linux', 'darwin' => 'macos', 'windows' => 'windows' }.freeze
    EXTS = { 'linux' => 'so', 'darwin' => 'dylib', 'windows' => 'dll' }.freeze
    CPU_ARCHS = { 'x86_64' => 'amd64', 'aarch64' => 'arm64' }.freeze
    SIZEOF_INT32 = 32 / 8
    BUFFER_HEADER_SIZE = SIZEOF_INT32 * 2
    MINIMUM_ALLOCATION = 1024

    os_path =
      if FFI::Platform::OS == 'linux' && RbConfig::CONFIG['arch'].include?('musl')
        'linux-musl'
      else
        OS_PATHS[FFI::Platform::OS]
      end
    raise UnsupportedPlatformError, "Unsupported operating system: #{FFI::Platform::OS}" unless os_path

    cpu_arch = CPU_ARCHS[FFI::Platform::ARCH]
    raise UnsupportedPlatformError, "Unsupported CPU: #{FFI::Platform::CPU_ARCH}" unless cpu_arch

    ext = EXTS.fetch(FFI::Platform::OS)
    lib_path = File.expand_path(File.join(__dir__, 'output', os_path, cpu_arch))

    # To properly load libgo.so.16 on Alpine, we need to change to lib path directory
    Dir.chdir(lib_path) do
      ffi_lib File.join(lib_path, "libplugtest.#{ext}")
    end

    attach_function :toUpper, %i[pointer int32 pointer int32], :int32
    attach_function :calculatePi, %i[int32 pointer int32], :int32
    attach_function :sleepTest, [:int32], :void, blocking: true
    attach_function :addInt32, %i[int32 int32], :int32
    attach_function :addInt64, %i[int64 int64], :int64
    attach_function :addDouble, %i[double double], :double

    def string_to_cbuffer(input)
      buffer_ptr = FFI::MemoryPointer.new(1, BUFFER_HEADER_SIZE + input.length, false)
      buffer_ptr.put_int32(0, input.length)
      buffer_ptr.put_int32(SIZEOF_INT32, 0) # Reserved - must be zero
      buffer_ptr.put_string(BUFFER_HEADER_SIZE, input)
      buffer_ptr
    end

    def cbuffer_to_string(buffer)
      length = buffer.get_int32(0)
      if length >= 0
        buffer_ptr.get_string(BUFFER_HEADER_SIZE, length)
      else
        temp_to_string(buffer, length)
      end
    end

    def temp_to_string(buffer, length)
      length = 0 - length
      filename = buffer_ptr.get_string(BUFFER_HEADER_SIZE, length)
      # Read file with name in payload, and replace payload
      bytes = IO.binread(filename)
      File.delete(filename)
      bytes
    end

    def allocate_cbuffer(size)
      size = [size, MINIMUM_ALLOCATION].max
      buffer_ptr = FFI::MemoryPointer.new(1, BUFFER_HEADER_SIZE + size, false)
      buffer_ptr.put_int32(0, size)
      buffer_ptr.put_int32(SIZEOF_INT32, 0) # Reserved - must be zero
      buffer_ptr
    end
  end
end
