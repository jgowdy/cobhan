# frozen_string_literal: true

class CobhanApp
  include CobhanModule
end

RSpec.describe 'Integration' do
  before :all do
    CobhanApp::FFI.init(LIB_ROOT_PATH, LIB_NAME)
  end

  subject(:instance) { CobhanApp.new }

  it 'returns upper value' do
    expect(instance.to_upper('Initial value')).to eq('INITIAL VALUE')
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

  it 'filters json' do
    json = '{"test":"foo","test2":"kittens"}'
    result = instance.filter_json(json, 'foo')
    expect(result).to eq('{"test2":"kittens"}')
  end

  it 'base64 encodes' do
    result = instance.base64_encode('Test')
    expect(result).to eq("VGVzdA==")
  end
end
