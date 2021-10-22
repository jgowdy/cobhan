# frozen_string_literal: true

RSpec.describe CobhanDemoLib do
  it "has a version number" do
    expect(CobhanDemoLib::VERSION).not_to be nil
  end

  it "does something useful" do
    require 'cobhan'
    expect(Cobhan.load_library).not_to be nil
    expect(CobhanDemoLib.load_library).not_to be nil
  end
end
