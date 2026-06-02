import ArgumentParser
import Foundation
import NTRIP
import RTCM3

@main
struct NTRIPClientTool: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "ntrip-client",
        abstract: "A Swift-based NTRIP client for GNSS data streaming."
    )

    @Option(name: .shortAndLong, help: "Path to a JSON configuration file.")
    var config: String?

    @Option(name: .shortAndLong, help: "Caster host address.")
    var host: String?

    @Option(name: .shortAndLong, help: "Caster port.")
    var port: Int?

    @Option(name: .shortAndLong, help: "Mountpoint to connect to.")
    var mountpoint: String?

    @Option(name: .shortAndLong, help: "Username for authentication.")
    var user: String?

    @Option(name: .customShort("P"), help: "Password for authentication.")
    var password: String?

    @Flag(name: .customShort("x"), help: "Parse RTCM3 messages.")
    var parse: Bool = false

    func run() async throws {
        var logDir = "log"
        var finalHost = ""
        var finalPort = 2101
        var finalMountpoint = ""
        var finalUser = ""
        var finalPassword = ""

        if let configPath = config {
            do {
                let cfg = try ConfigLoader.load(ClientConfig.self, from: configPath)
                logDir = cfg.logging?.logDirectory ?? logDir
                finalHost = cfg.host
                finalPort = cfg.port
                finalMountpoint = cfg.mountpoint
                finalUser = cfg.user ?? ""
                finalPassword = cfg.password ?? ""
            } catch {
                print("Failed to load config: \(error)")
                throw error
            }
        }

        // Override with command line options if provided
        if let h = host { finalHost = h }
        if let p = port { finalPort = p }
        if let m = mountpoint { finalMountpoint = m }
        if let u = user { finalUser = u }
        if let pw = password { finalPassword = pw }

        guard !finalHost.isEmpty && !finalMountpoint.isEmpty else {
            print("Error: Missing host or mountpoint.")
            return
        }

        _ = Logger.shared.initialize(logDirectory: logDir, appName: "ntrip-client")
        defer { Logger.shared.close() }

        LOG_INFO("Starting NTRIP Client to \(finalHost):\(finalPort)/\(finalMountpoint)")

        let options = NTRIPClient.Options(
            server: finalHost,
            port: finalPort,
            mountpoint: finalMountpoint,
            user: finalUser,
            password: finalPassword
        )

        let client = NTRIPClient(options: options)
        let rtcmParser = RTCM3Parser()

        do {
            let stream = try await client.start()
            for await data in stream {
                if parse {
                    rtcmParser.handleData(data)
                } else {
                    // Just output raw data to stdout or a file
                    FileHandle.standardOutput.write(data)
                }
            }
        } catch {
            LOG_ERROR("Client error: \(error)")
            throw error
        }
    }
}
