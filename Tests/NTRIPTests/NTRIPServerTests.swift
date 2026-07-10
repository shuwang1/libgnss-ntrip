import XCTest
@testable import NTRIP

final class NTRIPServerTests: XCTestCase {
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
    
    func testServerHandshakeSuccess() async throws {
        mockServer.requestHandler = { req in
            XCTAssertTrue(req.contains("SOURCE pwd /MOUNTPOINT"))
            return "ICY 200 OK\r\n\r\n"
        }
        
        let options = NTRIPServer.Options(host: "127.0.0.1", port: mockServer.port, mountpoint: "MOUNTPOINT", password: "pwd")
        let server = NTRIPServer(options: options)
        
        try await server.connect()
        try await server.send(data: Data([0x01, 0x02]))
        server.close()
    }
    
    func testServerHandshakeFailure() async {
        mockServer.requestHandler = { req in
            return "HTTP/1.1 401 Unauthorized\r\n\r\n"
        }
        
        let options = NTRIPServer.Options(host: "127.0.0.1", port: mockServer.port, mountpoint: "MOUNTPOINT", password: "pwd")
        let server = NTRIPServer(options: options)
        
        do {
            try await server.connect()
            XCTFail("Should have thrown")
        } catch {
            // Expected failure
        }
    }
}
