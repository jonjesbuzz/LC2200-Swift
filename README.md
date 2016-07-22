# LC-2200 in Swift

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

A 16-bit LC-2200 assembler and simulator, written entirely in Swift.

## Usage
To assemble a file, give it the `.s` file.  It will assemble, write the output, and run it.

To run an already-assembled file, give it the `.lc` file, and it will load it straight into memory.

This code was tested using the February 25th Development Snapshot of Swift on macOS.

## Building
With the Swift open-source toolchain [installed and set in your path](https://swift.org/download/#latest-development-snapshots):

```
swift build -c release
.build/release/LC2200Kit [filename.lc] [--debug]
```

## Debug Mode
Running the simulator with `--debug` will enable a GDB-like debugger.

`help` will print out usage information.

## Tests
These (probably) need to be written at some point. `:|`

## Framework
This simulator can also be compiled as a framework for iOS, macOS, tvOS (LOL), and watchOS (LOLOLOL).  Use [Carthage](https://github.com/Carthage/Carthage) to install the framework into your project.

## Documentation

```swift
// TODO
```
