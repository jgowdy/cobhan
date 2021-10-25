require 'cobhan'

module CobhanDemoLib
  module FFI
    extend Cobhan

    load_library File.join(__dir__, '..', 'binaries'), 'cobhan-demo-lib'

    attach_function :toUpper, %i[pointer pointer], :int32
    attach_function :calculatePi, %i[int32 pointer int32], :int32
    attach_function :sleepTest, [:int32], :void, blocking: true
    attach_function :addInt32, %i[int32 int32], :int32
    attach_function :addInt64, %i[int64 int64], :int64
    attach_function :addDouble, %i[double double], :double
  end

  extend self

  def to_upper(input)
    in_buffer = FFI.string_to_cbuffer(input)
    out_buffer = FFI.allocate_cbuffer(input.size)

    result, str = FFI.toUpper(in_buffer, out_buffer)
    raise 'Failed to convert toUpper' if result.negative?

    FFI.cbuffer_to_string(str)
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

  def add_int32(first, second)
    CobhanFFI.addInt32(first, second)
  end

  def add_int64(first, second)
    CobhanFFI.addInt64(first, second)
  end

  def add_double(first, second)
    CobhanFFI.addDouble(first, second)
  end
end