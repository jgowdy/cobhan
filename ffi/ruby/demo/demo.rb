# frozen_string_literal: true

require 'cobhan'
require_relative './../spec/support/download_binary'
require_relative './../spec/support/cobhan_module'


LIB_ROOT_PATH =  File.join(File.expand_path(File.dirname(__FILE__)), '../tmp')
LIB_NAME = 'libcobhandemo'

download_binary(LIB_ROOT_PATH, LIB_NAME)

class CobhanDemo
  include CobhanModule

  FFI.init(LIB_ROOT_PATH, LIB_NAME)
end

demo = CobhanDemo.new
puts demo.add_int32(2.9, 2.0)
puts demo.add_int64(2.9, 2.0)
puts demo.add_double(2.9, 2.0)
puts demo.to_upper('foo bar baz')
puts demo.filter_json('{"foo":"bar","baz":"qux"}', 'foo')
puts demo.base64_encode('Test')
puts "Sleep: #{t1 = Time.now; demo.sleep_test(1); t2 = Time.now; t2-t1}"
