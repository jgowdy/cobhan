# frozen_string_literal: true

require 'cobhan-demo-lib'
# require 'thread'

class CobhanDemo
  include CobhanDemoLib
end

demo = CobhanDemo.new
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
