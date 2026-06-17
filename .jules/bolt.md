## 2024-05-01 - Swift Compiler Crash on Ubuntu
**Learning:** `swift build` and `swift test` commands for this Swift 6 project face compiler segmentation faults on Ubuntu 24.04 setups due to a `clang::RawComment::RawComment` crash originating from swift-docc-plugin/manifest compilation.
**Action:** Use localized test scripts (omitting swiftpm) to verify core logic mathematically when encountering this crash, or test via an alternate environment.
## 2024-05-24 - Compiler segfaults with Foundation on Ubuntu
**Learning:** Testing logic involving Foundation (like `Data`) on certain Ubuntu environments with `swiftc` or `swift build` can lead to compiler segmentation faults (Signal 11).
**Action:** When developing standalone test scripts to verify algorithms locally, avoid `import Foundation`. Instead, use `import Glibc` and replace `Data` with `[UInt8]` arrays to bypass the compiler bug and successfully validate core mathematical logic like CRC computations.
