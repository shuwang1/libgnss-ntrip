import XCTest
@testable import RTCM3

final class CRC24Tests: XCTestCase {
    func testCRCCalculation() {
        // Test with a known RTCM3 header
        // D3 00 13
        let data = Data([0xD3, 0x00, 0x13])
        let crc = CRC24.calculate(data: data)
        
        // RTCM3 CRC-24 with polynomial 0x1864CFB for D3 00 13 yields 0x8E3D34
        XCTAssertEqual(crc, 0x8E3D34) 
    }
}
