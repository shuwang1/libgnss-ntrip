import Foundation

/// A client for connecting to an NTRIP Caster and receiving GNSS correction data.
public final class NTRIPClient: @unchecked Sendable {
    /// Configuration options for the NTRIP client.
    public struct Options {
        /// The hostname or IP address of the NTRIP Caster.
        public var server: String
        /// The port number of the NTRIP Caster (default is 2101).
        public var port: Int
        /// The mountpoint to request data from.
        public var mountpoint: String
        /// The username for Basic Authentication.
        public var user: String
        /// The password for Basic Authentication.
        public var password: String
        
        /// Initializes a new set of NTRIP client options.
        public init(server: String, port: Int = 2101, mountpoint: String, user: String = "", password: String = "") {
            self.server = server
            self.port = port
            self.mountpoint = mountpoint
            self.user = user
            self.password = password
        }
    }
    
    private let options: Options
    private var socket: NTRIPSocket?
    
    /// Initializes a new NTRIP client with the specified options.
    /// - Parameter options: The connection options.
    public init(options: Options) {
        self.options = options
    }
    
    /// Starts the NTRIP client and returns an asynchronous stream of correction data.
    /// - Returns: An `AsyncStream<Data>` that yields data as it is received from the caster.
    /// - Throws: `SocketError` or connection errors if the handshake fails.
    public func start() async throws -> AsyncStream<Data> {
        let socket = NTRIPSocket()
        try await socket.connect(host: options.server, port: options.port)
        self.socket = socket
        
        try await sendHandshake()
        try await verifyResponse()
        
        return AsyncStream { continuation in
            let task = Task {
                do {
                    while !Task.isCancelled {
                        let data = try await socket.read(maxLength: 4096)
                        continuation.yield(data)
                    }
                } catch {
                    LOG_ERROR("NTRIP stream read error: \(error)")
                    continuation.finish()
                }
            }
            
            continuation.onTermination = { _ in
                task.cancel()
                socket.close()
            }
        }
    }
    
    private func sendHandshake() async throws {
        let auth = NTRIPUtil.encodeBase64(user: options.user, password: options.password)
        let handshake = [
            "GET /\(options.mountpoint) HTTP/1.0",
            "User-Agent: NTRIP SwiftClient",
            "Authorization: Basic \(auth)",
            "Connection: close",
            "",
            ""
        ].joined(separator: "\r\n")
        
        guard let data = handshake.data(using: .utf8) else { return }
        try await socket?.write(data: data)
    }
    
    private func verifyResponse() async throws {
        // Read response headers
        let data = try await socket?.read(maxLength: 1024) ?? Data()
        guard let response = String(data: data, encoding: .utf8) else {
            throw SocketError.readFailed(-1)
        }
        
        if response.contains("ICY 200 OK") || response.contains("HTTP/1.0 200 OK") || response.contains("HTTP/1.1 200 OK") {
            LOG_INFO("NTRIP Handshake successful")
        } else {
            LOG_ERROR("NTRIP Handshake failed: \(response)")
            throw SocketError.connectionFailed("Handshake failed")
        }
    }
}
