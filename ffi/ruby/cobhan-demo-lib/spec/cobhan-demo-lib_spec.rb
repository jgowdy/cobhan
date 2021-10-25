# frozen_string_literal: true

RSpec.describe CobhanDemoLib do
  it 'has a version number' do
    expect(CobhanDemoLib::VERSION).not_to be nil
  end

  it 'FFI has Cobhan methods' do
    expect(CobhanDemoLib::FFI.methods).to include(:load_library)
  end

  it 'adds int32s' do
    expect(CobhanDemoLib.add_int32(2.9, 2.0)).to eq(4)
  end

  it 'adds int64s' do
    expect(CobhanDemoLib.add_int64(2.9, 2.0)).to eq(4)
  end

  it 'adds doubles' do
    expect(CobhanDemoLib.add_double(2.9, 2.0)).to eq(4.9)
  end

  it 'uppercases' do
    expect(CobhanDemoLib.to_upper('foo bar baz')).to eq('FOO BAR BAZ')
  end

  it 'filters json' do
    expect(CobhanDemoLib.filter_json('{"foo":"bar","baz":"qux"}', 'bar')).to eq('{"baz":"qux"}')
  end

  it 'sleeps' do
    expect(CobhanDemoLib.sleep_test(0)).to be_nil
  end
end
