import Foundation
#if os(Linux)
import Glibc
#else
import Darwin
#endif

class MockTCPServer: @unchecked Sendable {
    var fd: Int32 = -1
    let port: Int
    var task: Task<Void, Never>?
    
    // For handling responses based on request
    var requestHandler: (@Sendable (String) -> String)?
    // Optional flag to not close connection immediately (to simulate stream)
    var closeAfterResponse: Bool = true

    init() {
        #if os(Linux)
        let sockStream = Int32(SOCK_STREAM.rawValue)
        #else
        let sockStream = SOCK_STREAM
        #endif
        
        let newFd = socket(AF_INET, sockStream, 0)
        
        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_addr.s_addr = INADDR_ANY.byteSwapped // 0.0.0.0
        
        var boundPort: Int = 0
        for p in 10000...60000 {
            addr.sin_port = in_port_t(p).bigEndian
            var addrCpy = addr
            let res = withUnsafePointer(to: &addrCpy) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { ptr in
                    #if os(Linux)
                    return Glibc.bind(newFd, ptr, socklen_t(MemoryLayout<sockaddr_in>.size))
                    #else
                    return Darwin.bind(newFd, ptr, socklen_t(MemoryLayout<sockaddr_in>.size))
                    #endif
                }
            }
            if res == 0 {
                boundPort = p
                break
            }
        }
        self.port = boundPort
        self.fd = newFd
        
        #if os(Linux)
        Glibc.listen(newFd, 5)
        #else
        Darwin.listen(newFd, 5)
        #endif
    }
    
    func start() {
        task = Task {
            while !Task.isCancelled {
                var clientAddr = sockaddr_in()
                var clientLen = socklen_t(MemoryLayout<sockaddr_in>.size)
                
                #if os(Linux)
                let clientFd = withUnsafeMutablePointer(to: &clientAddr) {
                    $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { ptr in
                        Glibc.accept(fd, ptr, &clientLen)
                    }
                }
                #else
                let clientFd = withUnsafeMutablePointer(to: &clientAddr) {
                    $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { ptr in
                        Darwin.accept(fd, ptr, &clientLen)
                    }
                }
                #endif
                
                guard clientFd >= 0 else { continue }
                
                Task {
                    var buffer = [UInt8](repeating: 0, count: 4096)
                    #if os(Linux)
                    let readLen = Glibc.read(clientFd, &buffer, 4096)
                    #else
                    let readLen = Darwin.read(clientFd, &buffer, 4096)
                    #endif
                    
                    if readLen > 0, let req = String(bytes: buffer.prefix(readLen), encoding: .utf8), let handler = self.requestHandler {
                        let responseStr = handler(req)
                        let responseData = Array(responseStr.utf8)
                        
                        _ = responseData.withUnsafeBufferPointer { ptr in
                            #if os(Linux)
                            Glibc.write(clientFd, ptr.baseAddress!, ptr.count)
                            #else
                            Darwin.write(clientFd, ptr.baseAddress!, ptr.count)
                            #endif
                        }
                    }
                    
                    if self.closeAfterResponse {
                        #if os(Linux)
                        Glibc.close(clientFd)
                        #else
                        Darwin.close(clientFd)
                        #endif
                    }
                }
            }
        }
    }
    
    func stop() {
        task?.cancel()
        if fd != -1 {
            #if os(Linux)
            Glibc.close(fd)
            #else
            Darwin.close(fd)
            #endif
            fd = -1
        }
    }
}
