import XCTest
@testable import NTRIP

final class ConfigTests: XCTestCase {
    func testLoadClientConfig() throws {
        let json = """
        {
            "host": "euref-ip.net",
            "port": 2101,
            "mountpoint": "BRUX",
            "user": "testuser",
            "password": "testpassword",
            "logging": {
                "log_dir": "custom_log"
            }
        }
        """
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("client_config.json")
        try json.write(to: url, atomically: true, encoding: .utf8)
        
        let config = try ConfigLoader.load(ClientConfig.self, from: url.path)
        XCTAssertEqual(config.host, "euref-ip.net")
        XCTAssertEqual(config.port, 2101)
        XCTAssertEqual(config.mountpoint, "BRUX")
        XCTAssertEqual(config.user, "testuser")
        XCTAssertEqual(config.password, "testpassword")
        XCTAssertEqual(config.logging?.logDirectory, "custom_log")
    }

    func testLoadConfigError() {
        XCTAssertThrowsError(try ConfigLoader.load(ClientConfig.self, from: "/non/existent/path/config.json"))
    }
}
