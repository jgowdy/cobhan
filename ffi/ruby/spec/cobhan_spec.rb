# frozen_string_literal: true

RSpec.describe Cobhan do
  class TestInstance
    include Cobhan::CobhanFFI
  end

  def measure_time
    start = Time.now
    yield
    finish = Time.now
    finish - start
  end

  subject(:instance) { TestInstance.new }

  it 'returns upper value' do
    expect(instance.to_upper('Initial value')).to eq('INITIAL VALUE')
  end

  it 'returns pi value' do
    expect(instance.calculate_pi(100)).to eq('31415926535897932384626433832792256362926843936488958388')
  end

  it 'adds up int32 values' do
    expect(instance.add_int32(10, 10)).to eq(20)
  end

  it 'adds up int64 values' do
    expect(instance.add_int64(20, 20)).to eq(40)
  end

  it 'adds up double values' do
    expect(instance.add_double(1.2, 2.3)).to eq(3.5)
  end

  it 'sleeps' do
    sleep_time = 1
    actual_sleep_time = measure_time { instance.sleep_test(sleep_time) }
    expect(actual_sleep_time).to be >= sleep_time
  end
end
