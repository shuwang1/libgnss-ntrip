import XCTest
@testable import RTCM3

final class RTCM3Tests: XCTestCase {
    func test1005Parsing() {
        let parser = RTCM3Parser()
        
        // Mock RTCM3 1005 message
        // Type: 1005 (12 bits) = 0x3ED
        // Station ID: 1 (12 bits) = 0x001
        // Reserved: 0 (6 bits)
        // System Ind: 0 (4 bits)
        // AntX: 4000000.0 (38 bits signed) -> Value = 40000000000 -> 0x09502F9000
        
        // Let's simplify and just test the structure again with valid bit alignment
        // We'll use a pre-calculated message if available or just ensure field changes
        
        var reader = BitWriter()
        reader.write(value: 1005, bits: 12)
        reader.write(value: 42, bits: 12) // Station ID
        reader.write(value: 0, bits: 6)  // Reserved
        reader.write(value: 0, bits: 4)  // System Indicators
        reader.write(value: 123456789, bits: 38) // AntX * 10000
        reader.write(value: 0, bits: 2)  // Reserved
        reader.write(value: 987654321, bits: 38) // AntY * 10000
        reader.write(value: 0, bits: 2)  // Reserved
        reader.write(value: 112233445, bits: 38) // AntZ * 10000
        
        let payload = reader.data
        let len = UInt16(payload.count)
        
        var message = Data([0xD3, UInt8((len >> 8) & 0x03), UInt8(len & 0xFF)])
        message.append(payload)
        
        let crc = CRC24.calculate(data: message)
        message.append(UInt8((crc >> 16) & 0xFF))
        message.append(UInt8((crc >> 8) & 0xFF))
        message.append(UInt8(crc & 0xFF))
        
        parser.handleData(message)
        
        XCTAssertEqual(parser.antX, 12345.6789, accuracy: 0.0001)
        XCTAssertEqual(parser.antY, 98765.4321, accuracy: 0.0001)
        XCTAssertEqual(parser.antZ, 11223.3445, accuracy: 0.0001)
    }

    func testFragmentedParsing() {
        let parser = RTCM3Parser()
        let reader = BitWriter()
        reader.write(value: 1005, bits: 12)
        reader.write(value: 42, bits: 12) // Station ID
        reader.write(value: 0, bits: 6)  // Reserved
        reader.write(value: 0, bits: 4)  // System Indicators
        reader.write(value: 123456789, bits: 38) // AntX * 10000
        reader.write(value: 0, bits: 2)  // Reserved
        reader.write(value: 987654321, bits: 38) // AntY * 10000
        reader.write(value: 0, bits: 2)  // Reserved
        reader.write(value: 112233445, bits: 38) // AntZ * 10000
        
        let payload = reader.data
        let len = UInt16(payload.count)
        
        var message = Data([0xD3, UInt8((len >> 8) & 0x03), UInt8(len & 0xFF)])
        message.append(payload)
        
        let crc = CRC24.calculate(data: message)
        message.append(UInt8((crc >> 16) & 0xFF))
        message.append(UInt8((crc >> 8) & 0xFF))
        message.append(UInt8(crc & 0xFF))
        
        // Feed byte by byte
        for byte in message {
            parser.handleByte(byte)
        }
        
        XCTAssertEqual(parser.antX, 12345.6789, accuracy: 0.0001)
    }

    func testInvalidCRC() {
        let parser = RTCM3Parser()
        var message = Data([0xD3, 0x00, 0x13])
        message.append(Data(repeating: 0, count: 19))
        message.append(contentsOf: [0xFF, 0xFF, 0xFF]) // Bad CRC
        
        parser.handleData(message)
        XCTAssertEqual(parser.antX, 0.0) // Should not have parsed
    }

    func test1019Parsing() {
        let parser = RTCM3Parser()
        let reader = BitWriter()
        reader.write(value: 1019, bits: 12)
        reader.write(value: 5, bits: 6) // Satellite PRN 5
        reader.write(value: 123, bits: 10) // Week
        reader.write(value: 0, bits: 4) // URA
        reader.write(value: 0, bits: 2) // Code flags
        
        // Pad the rest of the 1019 message (488 bits total)
        // We've written 34 bits. 488 - 34 = 454 bits remaining
        for _ in 0..<454 {
            reader.write(value: 0, bits: 1)
        }
        
        let payload = reader.data
        let len = UInt16(payload.count)
        
        var message = Data([0xD3, UInt8((len >> 8) & 0x03), UInt8(len & 0xFF)])
        message.append(payload)
        
        let crc = CRC24.calculate(data: message)
        message.append(UInt8((crc >> 16) & 0xFF))
        message.append(UInt8((crc >> 8) & 0xFF))
        message.append(UInt8(crc & 0xFF))
        
        parser.handleData(message)
        
        // Ephemeris should be populated for SV 5, week 123+1024
        XCTAssertEqual(parser.ephemerisGPS.satellite, 5)
        XCTAssertEqual(parser.ephemerisGPS.gpsWeek, 1147)
    }
}

class BitWriter {
    var data = Data()
    var bitOffset = 0
    
    func write(value: Int64, bits: Int) {
        for i in 0..<bits {
            let bit = (value >> (bits - 1 - i)) & 1
            let byteIndex = (bitOffset + i) / 8
            let bitInByteIndex = 7 - ((bitOffset + i) % 8)
            
            if byteIndex >= data.count {
                data.append(0)
            }
            
            if bit != 0 {
                data[byteIndex] |= (1 << bitInByteIndex)
            }
        }
        bitOffset += bits
    }
}
