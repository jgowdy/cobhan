# Cobhan

## Usage

Start a shell

    ./bin/docker.sh sh

Start a shell for specific distro

    DISTRO=debian ./bin/docker.sh sh

Run tests

    ./bin/docker.sh rspec spec

Build a single gem for all platforms

    ./bin/docker.sh rake build

Build gem per platform

    ./bin/docker.sh rake build_many

Build a gem and run a smoke test

    ./bin/docker.sh rake build_smoke_test

### Starting shell


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jgowdy/cobhan.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
