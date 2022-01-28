# Cobhan Demo

To run the demo, install dependencies first:

```
bundle install
```

Then, download the binary file for your platform from the [releases page](https://github.com/jgowdy/cobhan/releases/tag/current).

For MacOS x64, that would be:

```
wget https://github.com/jgowdy/cobhan/releases/download/current/libcobhandemo-x64.dylib
```

Finally, run the demo with the file as the first argument:

```
bundle exec ruby demo.rb ./libcobhandemo-x64.dylib
```
