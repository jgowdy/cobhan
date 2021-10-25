require 'cobhan'

module CobhanDemoLib
  module FFI
    extend Cobhan

    load_library File.join(__dir__, '..', 'binaries'), 'libcobhandemo-x64'

    attach_function :addInt32, %i[int32 int32], :int32
    attach_function :addInt64, %i[int64 int64], :int64
    attach_function :addDouble, %i[double double], :double
    attach_function :toUpper, %i[pointer pointer], :int32
    attach_function :filterJson, %i[pointer pointer pointer], :int32
    attach_function :sleepTest, [:int32], :void, blocking: true
  end

  extend self

  def add_int32(first, second)
    FFI.addInt32(first, second)
  end

  def add_int64(first, second)
    FFI.addInt64(first, second)
  end

  def add_double(first, second)
    FFI.addDouble(first, second)
  end

  def to_upper(input)
    in_buffer = FFI.string_to_cbuffer(input)
    out_buffer = FFI.allocate_cbuffer(input.size)

    result = FFI.toUpper(in_buffer, out_buffer)
    raise 'Failed to convert toUpper' if result.negative?

    FFI.cbuffer_to_string(out_buffer)
  end

  def filter_json(json_input, disallowed_value)
    json_input_buffer = FFI.string_to_cbuffer(json_input)
    disallowed_value_buffer = FFI.string_to_cbuffer(disallowed_value)
    json_output_buffer = FFI.allocate_cbuffer(json_input.length)

    result = FFI.filterJson(json_input_buffer, disallowed_value_buffer, json_output_buffer)
    raise 'Failed to calculate pi' if result.negative?

    FFI.cbuffer_to_string(json_output_buffer)
  end

  def sleep_test(seconds)
    FFI.sleepTest(seconds)
  end
end