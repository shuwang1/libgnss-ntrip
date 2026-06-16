## 2024-05-24 - Compiler segfaults with Foundation on Ubuntu
**Learning:** Testing logic involving Foundation (like `Data`) on certain Ubuntu environments with `swiftc` or `swift build` can lead to compiler segmentation faults (Signal 11).
**Action:** When developing standalone test scripts to verify algorithms locally, avoid `import Foundation`. Instead, use `import Glibc` and replace `Data` with `[UInt8]` arrays to bypass the compiler bug and successfully validate core mathematical logic like CRC computations.

## 2024-06-16 - RTCM3 BitReader optimization
**Learning:** In the Swift codebase, `BitReader` class processing for parsing variable-length bit formats inside RTCM3 messages frequently iterated over individual bits, calculating array indices repeatedly. This generated O(N) index computation overhead that dramatically impacted performance when processing large RTCM3 binary payload streams.
**Action:** Implemented block-based chunking that operates on bytes and applies swift bitwise shift operations and masking to extract bits in blocks, replacing individual bit scanning with efficient chunk operations. In the future, optimize variable-length bit parsing by reading chunks rather than iterating individual bits.
