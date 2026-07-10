# libgnss-ntrip-swift: A modern, high-performance Swift implementation of the **NTRIP** (Networked Transport of RTCM via Internet Protocol) protocol.

[![CI](https://github.com/shuwang1/libntrip/actions/workflows/ci.yml/badge.svg)](https://github.com/shuwang1/libntrip/actions/workflows/ci.yml)[![codecov](https://codecov.io/gh/shuwang1/libgnss-ntrip/graph/badge.svg?token=OU0KH8GC6G)](https://codecov.io/gh/shuwang1/libgnss-ntrip)[![CodeFactor](https://www.codefactor.io/repository/github/shuwang1/libgnss-ntrip/badge)](https://www.codefactor.io/repository/github/shuwang1/libgnss-ntrip)[![Codacy Badge](https://app.codacy.com/project/badge/Grade/4575eccf14ad4ea8992712643d738983)](https://app.codacy.com/gh/shuwang1/libgnss-ntrip/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)
[![pages-build-deployment](https://github.com/shuwang1/libntrip/actions/workflows/pages/pages-build-deployment/badge.svg?branch=main)](https://github.com/shuwang1/libntrip/actions/workflows/pages/pages-build-deployment)

`libgnss-ntrip-swift` is a Swift 6 port and evolution of the original Orientable AI internal project. It provides a type-safe, asynchronous framework for streaming Global Navigation Satellite System (GNSS) correction data.

## Features

- **NTRIP Client**: Connect to Casters to receive real-time RTCM streams.
- **NTRIP Server**: Push GNSS data from local sources (files, stdin) to Casters.
- **RTCM3 Parser**: High-efficiency bit-level parsing for RTCM3 messages (Types 1005, 1006, 1019, etc.).
- **Modern Swift Architecture**:
    - **Structured Concurrency**: Native `async/await` and `AsyncStream` support.
    - **Cross-Platform**: Designed for Linux and macOS using portable POSIX networking.
    - **Type Safety**: Robust error handling and type-safe configuration via `Codable`.
- **CLI Tools**: Ready-to-use `ntrip-client` and `ntrip-server` executables.

## Project Structure

- `Sources/NTRIP`: Core protocol implementation, asynchronous sockets, and shared utilities.
- `Sources/RTCM3`: Message synchronization logic, CRC24 validation, and bit-level field extraction.
- `Sources/NTRIPClient`: Command-line interface for the NTRIP client.
- `Sources/NTRIPServer`: Command-line interface for the NTRIP server.

## Quick Start

### Build
```bash
swift build
```

### Run Client
```bash
.build/debug/ntrip-client --host euref-ip.net --mountpoint BRUX00BEL0 --parse
```

### Run Tests
```bash
swift test
```

## Documentation

- **Installation & Usage**: See [INSTALL.md](INSTALL.md) for detailed setup and execution instructions.
- **API Reference**: Generate local documentation with `swift package generate-documentation --target NTRIP`.

## License

Refer to [LICENSE.md](LICENSE.md) for licensing details. All Right Reserved by Shu Wang, <shuwang1@outlook.com>
