import Foundation

public final class NTRIPServer: @unchecked Sendable {
    public struct Options {
        public var host: String
        public var port: Int
        public var mountpoint: String
        public var password: String
        
        public init(host: String, port: Int = 2101, mountpoint: String, password: String = "") {
            self.host = host
            self.port = port
            self.mountpoint = mountpoint
            self.password = password
        }
    }
    
    private let options: Options
    private var socket: NTRIPSocket?
    
    public init(options: Options) {
        self.options = options
    }
    
    public func connect() async throws {
        let socket = NTRIPSocket()
        try await socket.connect(host: options.host, port: options.port)
        self.socket = socket
        
        try await sendHandshake()
        try await verifyResponse()
    }
    
    public func send(data: Data) async throws {
        try await socket?.write(data: data)
    }
    
    private func sendHandshake() async throws {
        // NTRIP 1.0 Source handshake (POST style but often specialized)
        // Original C code uses:
        // "SOURCE %s %s\r\nSource-Agent: NTRIP NtripServerPOSIX/%s\r\n\r\n"
        let handshake = [
            "SOURCE \(options.password) /\(options.mountpoint)",
            "Source-Agent: NTRIP SwiftServer",
            "Connection: close",
            "",
            ""
        ].joined(separator: "\r\n")
        
        guard let data = handshake.data(using: .utf8) else { return }
        try await socket?.write(data: data)
    }
    
    private func verifyResponse() async throws {
        let data = try await socket?.read(maxLength: 1024) ?? Data()
        guard let response = String(data: data, encoding: .utf8) else {
            throw SocketError.readFailed(-1)
        }
        
        if response.contains("ICY 200 OK") || response.contains("HTTP/1.0 200 OK") || response.contains("HTTP/1.1 200 OK") {
            LOG_INFO("NTRIP Server Handshake successful")
        } else {
            LOG_ERROR("NTRIP Server Handshake failed: \(response)")
            throw SocketError.connectionFailed("Handshake failed")
        }
    }
    
    public func close() {
        socket?.close()
    }
}
