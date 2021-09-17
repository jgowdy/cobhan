# frozen_string_literal: true

require_relative 'libplugtest'
require 'thread'

class Test
  include Libplugtest
end

test = Test.new

th = Thread.new do
  puts 'start sleeping'
  test.sleep_test 5
  # sleep 5
  puts 'done sleeping'
end

puts test.calculate_pi(100)
puts 'done pi'

puts test.add_int32(10, 10)
puts test.add_int64(20, 20)
puts test.add_double(1.2, 2.3)
puts test.to_upper('Initial value')

th.join
