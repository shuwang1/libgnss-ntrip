import Foundation

public struct CRC24 {
    public static func calculate(data: Data) -> UInt32 {
        var crc: UInt32 = 0
        for byte in data {
            crc ^= UInt32(byte) << 16
            for _ in 0..<8 {
                crc <<= 1
                if (crc & 0x1000000) != 0 {
                    crc ^= 0x01864cfb
                }
            }
        }
        return crc & 0xFFFFFF
    }
}
