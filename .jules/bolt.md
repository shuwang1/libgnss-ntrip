## 2024-05-30 - [Table-Driven CRC24 Optimization]
**Learning:** For continuous data stream validation like RTCM3, replacing bit-by-bit CRC calculation with a precomputed 256-element lookup table vastly decreases CPU usage by converting an O(N * 8) nested loop operation into an O(N) single loop with array indexing.
**Action:** Always favor lookup tables over explicit bit manipulations for checksum or hashing algorithms applied heavily on bitstreams.
