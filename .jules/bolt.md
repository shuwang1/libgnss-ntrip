## 2024-05-24 - Compiler segfaults with Foundation on Ubuntu
**Learning:** Testing logic involving Foundation (like `Data`) on certain Ubuntu environments with `swiftc` or `swift build` can lead to compiler segmentation faults (Signal 11).
**Action:** When developing standalone test scripts to verify algorithms locally, avoid `import Foundation`. Instead, use `import Glibc` and replace `Data` with `[UInt8]` arrays to bypass the compiler bug and successfully validate core mathematical logic like CRC computations.
## 2024-05-24 - RTCM3 Bit Reading Bottleneck
**Learning:** The RTCM3 parser heavily relies on reading non-byte-aligned bits. Looping over individual bits is an O(n) operation that causes a severe bottleneck when parsing many fields.
**Action:** Replace bit-by-bit looping with chunked byte-reading logic to significantly speed up decoding. Use `readBits` logic to process parts of each byte as single chunks.
