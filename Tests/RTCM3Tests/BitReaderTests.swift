import XCTest
@testable import RTCM3

final class BitReaderTests: XCTestCase {
    func testReadInt() {
        let data = Data([0b11010011, 0b00000000, 0b00010011]) // D3 00 13
        let reader = BitReader(data: data)
        
        XCTAssertEqual(reader.readInt(bits: 8), 0xD3)
        XCTAssertEqual(reader.readInt(bits: 6), 0)
        XCTAssertEqual(reader.readInt(bits: 10), 19)
        XCTAssertNil(reader.readInt(bits: 1)) // End of data
    }
    
    func testReadInt64Signed() {
        // 1101 0101
        let data = Data([0b11010101])
        let reader = BitReader(data: data)
        XCTAssertEqual(reader.readInt64(bits: 4), -3)
        XCTAssertEqual(reader.readInt64(bits: 4), 5)
    }
    
    func testReadFloat() {
        let data = Data([0b00000001])
        let reader = BitReader(data: data)
        XCTAssertEqual(reader.readFloat(bits: 8, factor: 0.5), 0.5)
    }
    
    func testReadFloatSign() {
        // -1 in 8 bits is 11111111
        let data = Data([0xFF])
        let reader = BitReader(data: data)
        XCTAssertEqual(reader.readFloatSign(bits: 8, factor: 0.1), -0.1, accuracy: 0.0001)
    }
}
