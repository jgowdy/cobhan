# Cobhan Demo

To run the demo, install dependencies first:

```bash
bundle install
```

Then, download the binary file for your platform from the [releases page](https://github.com/jgowdy/cobhan/releases/tag/current).

```bash
BINARY_FILE_NAME=libcobhandemo-x64.dylib # for macOS x64
wget https://github.com/jgowdy/cobhan/releases/download/current/$BINARY_FILE_NAME
```

Finally, run the demo with the binary file path as the first argument.

```bash
bundle exec ruby demo.rb ./$BINARY_FILE_NAME
```
