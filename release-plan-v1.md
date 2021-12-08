# Cobhan 1.0 Release Plan

## Supported host platforms

* Linux / glibc / amd64

* MacOS / amd64

## Supported library platforms

### Go

- [x] Cobhan
- [x] Libcobhandemo

### Rust

- [x] Cobhan
- [x] Libcobhandemo

## Supported FFI platforms

### Node.js 14

- [ ] ConsumerConsoleApp
- [ ] Libcobhandemo
- [ ] Libcobhan

### .NET Core 3

- [ ] ConsumerConsoleApp
- [ ] Libcobhandemo
- [ ] Libcobhan

### Ruby 3

- [ ] ConsumerConsoleApp
- [ ] Libcobhandemo
- [ ] Libcobhan

### Python 3

- [ ] ConsumerConsoleApp
- [ ] Libcobhandemo
- [ ] Libcobhan

### OpenJDK 11 JNA

- [ ] ConsumerConsoleApp
- [ ] Libcobhandemo
- [ ] Libcobhan

### OpenJDK 17 FFI

- [ ] ConsumerConsoleApp
- [ ] Libcobhandemo
- [ ] Libcobhan

## Components

### Libcobhan

Libcobhan is a per-FFI language library providing platform specific implementations of helper methods to handle allocation and usage of Cobhan specific buffers and platform specific FFI details.  Libcobhan also provides per-OS and per-CPU library selection functionality.

### Libcobhandemo

Libcobhandemo is a *sample* per-FFI language wrapper library that consumes the Rust or Go Libcobhandemo c-shared library (.so/.dylib).

### ConsumerConsoleApp

ConsumerConsoleApp is a *sample* per-FFI language console application that consumes a wrapper library like Libcobhandemo.  It has no knowledge of FFI or Cobhan.

## Minimum requirements

* Tests for all FFI platforms

## Specifically Excluded for 1.0

* Windows support
* arm64 support
* Linux / musl (Alpine) support
* FFI - Swift
* FFI - PHP
* Library - C
* gcc-go
* Custom base containers
