import XCTest
@testable import NTRIP

final class NTRIPClientTests: XCTestCase {
    var mockServer: MockTCPServer!
    
    override func setUp() {
        super.setUp()
        mockServer = MockTCPServer()
        mockServer.start()
    }
    
    override func tearDown() {
        mockServer.stop()
        mockServer = nil
        super.tearDown()
    }
    
    func testClientHandshakeSuccess() async throws {
        mockServer.requestHandler = { req in
            XCTAssertTrue(req.contains("GET /MOUNTPOINT"))
            XCTAssertTrue(req.contains("Authorization: Basic"))
            return "ICY 200 OK\r\n\r\nDataDataData"
        }
        
        let options = NTRIPClient.Options(server: "127.0.0.1", port: mockServer.port, mountpoint: "MOUNTPOINT", user: "test", password: "pwd")
        let client = NTRIPClient(options: options)
        
        let stream = try await client.start()
        
        for try await data in stream {
            let str = String(data: data, encoding: .utf8)
            XCTAssertEqual(str, "DataDataData")
            break
        }
    }
    
    func testClientHandshakeFailure() async {
        mockServer.requestHandler = { req in
            return "HTTP/1.1 401 Unauthorized\r\n\r\n"
        }
        
        let options = NTRIPClient.Options(server: "127.0.0.1", port: mockServer.port, mountpoint: "MOUNTPOINT")
        let client = NTRIPClient(options: options)
        
        do {
            _ = try await client.start()
            XCTFail("Should have thrown")
        } catch {
            // Expected failure
        }
    }
}
