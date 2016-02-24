# LC-2200 Simulator (Swift)

A 16-bit LC-2200 simulator.

## Usage
The simulator has two modes of operation (for now).

* **Compiled**: The assembly is compiled into the binary.  This is the only supported method on Linux until the Foundation library is updated to work on Linux.  The `lcas-swift.pl` assembler will generate an array that can be inserted in `Program.swift`  After this, build the project and run the program without a filename.
* **File**: The `lcas.pl` assembler can be used to generate a file that is then read by the front-end.

This code was tested using the Feb 8 Development Snapshot of Swift on OS X.

## Building
With the Swift open-source toolchain [installed and set in your path](https://swift.org/download/#latest-development-snapshots):

```
swift build -c release
.build/release/LC2200 [filename.lc] [--debug]
```

## Debug Mode
Running the simulator with `--debug` will enable a GDB-like debugger.

`help` will print out usage information.

## Tests
These need to be written at some point. :|

## Documentation

```swift
// TODO
```