puts build_info = `rake build`
gem_path = build_info.match(/built to (\S+)\./)[1]
puts `gem install #{gem_path}`

require 'cobhan'
require 'rspec'
load 'spec/cobhan_spec.rb'
RSpec::Core::Runner.invoke

# NOTE: The following runs the specs against the source which is not what we want.
# RSpec::Core::Runner.run(['spec/cobhan_spec.rb'])
