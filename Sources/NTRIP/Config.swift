import Foundation

public enum ConfigError: Error {
    case fileNotFound(String)
    case readError(Error)
    case parseError(Error)
}

public struct LoggingConfig: Codable {
    public var logDirectory: String?
    
    enum CodingKeys: String, CodingKey {
        case logDirectory = "log_dir"
    }
}

public struct ClientConfig: Codable {
    public var host: String
    public var port: Int
    public var mountpoint: String
    public var user: String?
    public var password: String?
    public var logging: LoggingConfig?
}

public struct ServerConfig: Codable {
    public var host: String
    public var port: Int
    public var mountpoint: String
    public var password: String
    public var logging: LoggingConfig?
}

public struct ConfigLoader {
    public static func load<T: Decodable>(_ type: T.Type, from path: String) throws -> T {
        let url = URL(fileURLWithPath: path)
        
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            LOG_ERROR("Could not read config file at \(path): \(error.localizedDescription)")
            throw ConfigError.readError(error)
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            return try decoder.decode(T.self, from: data)
        } catch {
            LOG_ERROR("JSON parse error for \(path): \(error.localizedDescription)")
            throw ConfigError.parseError(error)
        }
    }
}
