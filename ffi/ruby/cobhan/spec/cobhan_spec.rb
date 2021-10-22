# frozen_string_literal: true

RSpec.describe Cobhan do
  it "has a version number" do
    expect(Cobhan::VERSION).not_to be nil
  end

  it "does something useful" do
    Cobhan.load_library 'die'
  end
end
