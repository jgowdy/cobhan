# frozen_string_literal: true

require 'ffi'

module Cobhan
  UnsupportedPlatformError = Class.new(StandardError)

  module CobhanFFI
    extend FFI::Library

    if FFI::Platform::OS == 'linux' && Dir.glob('/lib/libc.musl*').length.positive?
      os_path = 'linux-musl'
      need_chdir = true
    else
      os_paths = { 'linux' => 'linux', 'darwin' => 'macos', 'windows' => 'windows' }.freeze
      os_path = os_paths[FFI::Platform::OS]
      need_chdir = false
      raise UnsupportedPlatformError, "Unsupported operating system: #{FFI::Platform::OS}" unless os_path
    end

    exts = { 'linux' => 'so', 'darwin' => 'dylib', 'windows' => 'dll' }.freeze
    ext = exts[FFI::Platform::OS]

    cpu_archs = { 'x86_64' => 'amd64', 'aarch64' => 'arm64' }.freeze
    cpu_arch = cpu_archs[FFI::Platform::ARCH]
    raise UnsupportedPlatformError, "Unsupported CPU: #{FFI::Platform::CPU_ARCH}" unless cpu_arch

    lib_path = File.expand_path(File.join(__dir__, 'output', os_path, cpu_arch))

    if need_chdir
      # Save current directory
      old_dir = Dir.pwd

      # Switch to library directory
      Dir.chdir(lib_path)
    end

    # NOTE: Absolute path is required here
    ffi_lib File.join(lib_path, "libplugtest.#{ext}")

    # Restore directory
    Dir.chdir(old_dir) if need_chdir

    attach_function :toUpper, %i[pointer int32 pointer int32], :int32
    attach_function :calculatePi, %i[int32 pointer int32], :int32
    attach_function :sleepTest, [:int32], :void, blocking: true
    attach_function :addInt32, %i[int32 int32], :int32
    attach_function :addInt64, %i[int64 int64], :int64
    attach_function :addDouble, %i[double double], :double

    def to_upper(input)
      in_ptr = FFI::MemoryPointer.from_string(input)
      out_ptr = FFI::MemoryPointer.new(1, in_ptr.size + 1, false)

      result = CobhanFFI.toUpper(input, input.length, out_ptr, out_ptr.size)
      raise 'Failed to convert toUpper' if result.negative?

      out_ptr.get_string(0, result)
    end

    def calculate_pi(digits)
      pi_buffer = FFI::MemoryPointer.new(1, digits + 1, false)

      result = CobhanFFI.calculatePi(digits, pi_buffer, pi_buffer.size)
      raise 'Failed to calculate pi' if result.negative?

      pi_buffer.get_string(0, result)
    end

    def sleep_test(seconds)
      CobhanFFI.sleepTest(seconds)
    end

    def add_int32(x, y)
      CobhanFFI.addInt32(x, y)
    end

    def add_int64(x, y)
      CobhanFFI.addInt64(x, y)
    end

    def add_double(x, y)
      CobhanFFI.addDouble(x, y)
    end
  end
end
