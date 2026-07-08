## 2024-05-01 - Swift Compiler Crash on Ubuntu
**Learning:** `swift build` and `swift test` commands for this Swift 6 project face compiler segmentation faults on Ubuntu 24.04 setups due to a `clang::RawComment::RawComment` crash originating from swift-docc-plugin/manifest compilation.
**Action:** Use localized test scripts (omitting swiftpm) to verify core logic mathematically when encountering this crash, or test via an alternate environment.
## 2024-05-24 - Compiler segfaults with Foundation on Ubuntu
**Learning:** Testing logic involving Foundation (like `Data`) on certain Ubuntu environments with `swiftc` or `swift build` can lead to compiler segmentation faults (Signal 11).
**Action:** When developing standalone test scripts to verify algorithms locally, avoid `import Foundation`. Instead, use `import Glibc` and replace `Data` with `[UInt8]` arrays to bypass the compiler bug and successfully validate core mathematical logic like CRC computations.
## 2024-05-24 - RTCM3 Bit Reading Bottleneck
**Learning:** The RTCM3 parser heavily relies on reading non-byte-aligned bits. Looping over individual bits is an O(n) operation that causes a severe bottleneck when parsing many fields.
**Action:** Replace bit-by-bit looping with chunked byte-reading logic to significantly speed up decoding. Use `readBits` logic to process parts of each byte as single chunks.
## 2024-06-13 - Optimize RTCM3 BitReader
**Learning:** Bit-by-bit reading logic in `RTCM3Parser.swift`'s `BitReader` class was a significant performance bottleneck due to excessive inner loop iterations when parsing RTCM3 messages.
**Action:** When extracting variable-length integers from bit streams, process the data in byte-sized chunks using bit shifts and masks instead of bit-by-bit to reduce loop overhead by 8x-15x.

## 2024-05-25 - BitReader Performance Bottleneck
**Learning:** RTCM3 parsing relies heavily on reading non-aligned bit fields. The original implementation of `BitReader` parsed these one bit at a time using an O(bits) loop, which resulted in unnecessary loops and slower performance.
**Action:** Replaced the bit-by-bit reading logic with a byte-by-byte approach using bitwise shifting. This transforms the operation from O(bits) to O(bytes), speeding up bit extraction significantly in `Sources/RTCM3/RTCM3Parser.swift`.
## 2024-06-16 - RTCM3 BitReader optimization
**Learning:** In the Swift codebase, `BitReader` class processing for parsing variable-length bit formats inside RTCM3 messages frequently iterated over individual bits, calculating array indices repeatedly. This generated O(N) index computation overhead that dramatically impacted performance when processing large RTCM3 binary payload streams.
**Action:** Implemented block-based chunking that operates on bytes and applies swift bitwise shift operations and masking to extract bits in blocks, replacing individual bit scanning with efficient chunk operations. In the future, optimize variable-length bit parsing by reading chunks rather than iterating individual bits.
