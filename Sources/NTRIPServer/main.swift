import ArgumentParser
import Foundation
import NTRIP

@main
struct NTRIPServerTool: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "ntrip-server",
        abstract: "A Swift-based NTRIP server for pushing GNSS data."
    )

    @Option(name: .shortAndLong, help: "Path to a JSON configuration file.")
    var config: String?

    @Option(name: .shortAndLong, help: "Caster host address.")
    var host: String?

    @Option(name: .shortAndLong, help: "Caster port.")
    var port: Int?

    @Option(name: .shortAndLong, help: "Mountpoint to push to.")
    var mountpoint: String?

    @Option(name: .shortAndLong, help: "Source password.")
    var password: String?

    @Option(name: .shortAndLong, help: "Input file to stream from (or - for stdin).")
    var input: String = "-"

    func run() async throws {
        var logDir = "log"
        var finalHost = ""
        var finalPort = 2101
        var finalMountpoint = ""
        var finalPassword = ""

        if let configPath = config {
            do {
                let cfg = try ConfigLoader.load(ServerConfig.self, from: configPath)
                logDir = cfg.logging?.logDirectory ?? logDir
                finalHost = cfg.host
                finalPort = cfg.port
                finalMountpoint = cfg.mountpoint
                finalPassword = cfg.password
            } catch {
                print("Failed to load config: \(error)")
                throw error
            }
        }

        // Override with command line options if provided
        if let h = host { finalHost = h }
        if let p = port { finalPort = p }
        if let m = mountpoint { finalMountpoint = m }
        if let pw = password { finalPassword = pw }

        guard !finalHost.isEmpty && !finalMountpoint.isEmpty else {
            print("Error: Missing host or mountpoint.")
            return
        }

        _ = Logger.shared.initialize(logDirectory: logDir, appName: "ntrip-server")
        defer { Logger.shared.close() }

        LOG_INFO("Starting NTRIP Server pushing to \(finalHost):\(finalPort)/\(finalMountpoint)")

        let options = NTRIPServer.Options(
            host: finalHost,
            port: finalPort,
            mountpoint: finalMountpoint,
            password: finalPassword
        )
        
        let server = NTRIPServer(options: options)
        
        do {
            try await server.connect()
            
            let fileHandle: FileHandle
            if input == "-" {
                fileHandle = .standardInput
            } else {
                guard let handle = FileHandle(forReadingAtPath: input) else {
                    LOG_ERROR("Could not open input file: \(input)")
                    return
                }
                fileHandle = handle
            }

            while true {
                let data = fileHandle.availableData
                if data.isEmpty { break }
                try await server.send(data: data)
            }
        } catch {
            LOG_ERROR("Server error: \(error)")
            throw error
        }
    }
}
