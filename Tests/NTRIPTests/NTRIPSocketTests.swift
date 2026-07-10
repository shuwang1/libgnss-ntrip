import XCTest
@testable import NTRIP

final class NTRIPSocketTests: XCTestCase {
    var server: MockTCPServer!
    
    override func setUp() {
        super.setUp()
        server = MockTCPServer()
        server.start()
    }
    
    override func tearDown() {
        server.stop()
        server = nil
        super.tearDown()
    }
    
    func testSocketConnectAndRead() async throws {
        server.requestHandler = { req in
            return "ECHO: " + req
        }
        
        let socket = NTRIPSocket()
        try await socket.connect(host: "127.0.0.1", port: server.port)
        
        let testData = "Hello Socket".data(using: .utf8)!
        try await socket.write(data: testData)
        
        let response = try await socket.read(maxLength: 1024)
        let responseString = String(data: response, encoding: .utf8)
        XCTAssertEqual(responseString, "ECHO: Hello Socket")
    }
    
    func testSocketConnectionFailure() async {
        let socket = NTRIPSocket()
        do {
            // Find an unused port that the mock server isn't on
            try await socket.connect(host: "127.0.0.1", port: 23456)
            XCTFail("Connection should have failed")
        } catch {
            // Expected
        }
    }
    
    func testSocketDNSFailure() async {
        let socket = NTRIPSocket()
        do {
            try await socket.connect(host: "invalid.hostname.local", port: 80)
            XCTFail("Connection should have failed due to DNS")
        } catch SocketError.dnsLookupFailed {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
