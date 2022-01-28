module CobhanModule
  module FFI
    extend Cobhan

    FUNCTIONS = [
      [ :addInt32, [ :int32, :int32 ], :int32 ],
      [ :addInt64, [ :int64, :int64 ], :int64 ],
      [ :addDouble, [ :double, :double ], :double ],
      [ :toUpper, [ :pointer, :pointer ], :int32 ],
      [ :filterJson, [ :pointer, :pointer, :pointer ], :int32 ],
      [ :sleepTest, [ :int32 ], :void, blocking: true ],
      [ :base64Encode, [ :pointer, :pointer], :int32 ],
    ]

    def self.init(lib_root_path, name)
      load_library(lib_root_path, name, FUNCTIONS)
    end
  end

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
    raise 'Failed to filter json' if result.negative?

    FFI.cbuffer_to_string(json_output_buffer)
  end

  def base64_encode(input)
    input_buffer = FFI.string_to_cbuffer(input)
    output_buffer = FFI.allocate_cbuffer(input.length)

    result = FFI.base64Encode(input_buffer, output_buffer)
    raise 'Failed to base64 encode' if result.negative?

    FFI.cbuffer_to_string(output_buffer)
  end

  def sleep_test(seconds)
    FFI.sleepTest(seconds)
  end
end
