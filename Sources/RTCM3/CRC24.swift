import Foundation

public struct CRC24 {
    // ⚡ Bolt: Precomputed lookup table for CRC24 calculation.
    // 💡 What: Replaces bit-by-bit CRC calculation with a precomputed 256-element lookup table.
    // 🎯 Why: Calculating CRC bit-by-bit requires an inner loop of 8 iterations per byte.
    //         Table lookup performs the same in O(1) time per byte.
    // 📊 Impact: Drastically reduces CPU cycles spent verifying RTCM3 message integrity,
    //            yielding significant performance improvements for large data streams.
    private static let table: [UInt32] = {
        var t = [UInt32](repeating: 0, count: 256)
        for i in 0..<256 {
            var crc = UInt32(i) << 16
            for _ in 0..<8 {
                crc <<= 1
                if (crc & 0x1000000) != 0 {
                    crc ^= 0x01864cfb
                }
            }
            t[i] = crc & 0xFFFFFF
        }
        return t
    }()

    public static func calculate(data: Data) -> UInt32 {
        var crc: UInt32 = 0
        for byte in data {
            let index = Int((crc >> 16) ^ UInt32(byte)) & 0xFF
            crc = ((crc << 8) ^ table[index]) & 0xFFFFFF
        }
        return crc
    }
}
