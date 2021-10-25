# frozen_string_literal: true

RSpec.describe CobhanDemoLib do
  it 'has a version number' do
    expect(CobhanDemoLib::VERSION).not_to be nil
  end

  it 'FFI has Cobhan methods' do
    expect(CobhanDemoLib::FFI.methods).to include(:load_library)
  end

  it 'uppercases' do
    expect(CobhanDemoLib.to_upper('foo bar baz')).to eq('FOO BAR BAZ')
  end
end
