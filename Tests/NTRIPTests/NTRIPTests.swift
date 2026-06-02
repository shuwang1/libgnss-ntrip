import XCTest
@testable import NTRIP

final class NTRIPTests: XCTestCase {
    func testBase64() {
        let encoded = NTRIPUtil.encodeBase64(user: "user", password: "pwd")
        XCTAssertEqual(encoded, "dXNlcjpwd2Q=")
    }
}
