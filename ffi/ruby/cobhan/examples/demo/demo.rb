# frozen_string_literal: true

require_relative './app'

class Demo
  include App
end

lib_file = ARGV[0]

if File.exists?(lib_file)
  puts "Testing: #{lib_file}"
  absolute_path = File.expand_path(lib_file)
  lib_root_path, name = Pathname.new(absolute_path).split.map(&:to_s)
  App::FFI.load_library_file(lib_root_path, name)
else
  abort('Library file is missing')
end

# require 'thread'

demo = Demo.new
puts demo.add_int32(2.9, 2.0)
puts demo.add_int64(2.9, 2.0)
puts demo.add_double(2.9, 2.0)
puts demo.to_upper('foo bar baz')
puts demo.filter_json('{"foo":"bar","baz":"qux"}', 'foo')

thread = Thread.new do
  puts 'going to sleep in thread...'
  demo.sleep_test(1)
  puts 'feeling rested in thread'
end

puts 'waiting for thread to join...'
thread.join
puts 'thread joined'
