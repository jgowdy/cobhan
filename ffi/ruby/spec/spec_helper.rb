# frozen_string_literal: true

require 'cobhan'

ROOT = File.expand_path('../', File.dirname(__FILE__))
LIB_ROOT_PATH = File.join(ROOT, 'tmp')
LIB_NAME = 'libcobhandemo'

# Load support files
Dir["#{ROOT}/spec/support/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.before(:suite) do
    download_binary(LIB_ROOT_PATH, LIB_NAME)
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
