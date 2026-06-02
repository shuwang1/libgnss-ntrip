import Foundation

/// Represents the severity level of a log message.
public enum LogLevel: Int {
    /// Detailed information for debugging.
    case debug = 0
    /// Normal operational messages.
    case info = 1
    /// Warnings about non-critical issues.
    case warn = 2
    /// Critical errors that may stop execution.
    case error = 3

    /// The string representation of the log level.
    var name: String {
        switch self {
        case .debug: return "DEBUG"
        case .info:  return "INFO"
        case .warn:  return "WARN"
        case .error: return "ERROR"
        }
    }
}

/// A thread-safe, singleton logger that handles mirrored output to stderr and a file.
public final class Logger: @unchecked Sendable {
    /// The shared singleton instance.
    public static let shared = Logger()
    
    /// The minimum level required for a message to be logged.
    public var logLevel: LogLevel = .info
    private var logFileHandle: FileHandle?
    private let lock = NSLock()

    private init() {}

    /// Initializes the logging system by creating the log directory and file.
    /// - Parameters:
    ///   - logDirectory: The directory where log files will be stored.
    ///   - appName: The prefix for the log filename.
    /// - Returns: `true` if initialization was successful, `false` otherwise.
    public func initialize(logDirectory: String, appName: String) -> Bool {
        let fileManager = FileManager.default
        
        // Ensure log directory exists
        if !fileManager.fileExists(atPath: logDirectory) {
            do {
                try fileManager.createDirectory(atPath: logDirectory, withIntermediateDirectories: true)
            } catch {
                print("Failed to create log directory: \(error)")
                return false
            }
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        let fileName = "\(appName)_\(timestamp).log"
        let filePath = (logDirectory as NSString).appendingPathComponent(fileName)

        if !fileManager.createFile(atPath: filePath, contents: nil) {
            print("Failed to create log file at \(filePath)")
            return false
        }

        lock.lock()
        logFileHandle = FileHandle(forWritingAtPath: filePath)
        lock.unlock()

        if logFileHandle == nil {
            print("Failed to open log file for writing at \(filePath)")
            return false
        }

        self.info("Logging initialized. File: \(filePath)")
        return true
    }

    public func close() {
        lock.lock()
        defer { lock.unlock() }
        try? logFileHandle?.close()
        logFileHandle = nil
    }

    public func write(level: LogLevel, file: String = #file, line: Int = #line, message: String) {
        guard level.rawValue >= logLevel.rawValue else { return }

        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .medium)
        let fileName = (file as NSString).lastPathComponent
        
        let stderrMessage = "[\(timestamp)] [\(level.name)] \(message)\n"
        let fileMessage = "[\(timestamp)] [\(level.name)] [\(fileName):\(line)] \(message)\n"

        lock.lock()
        defer { lock.unlock() }

        // stderr
        if let data = stderrMessage.data(using: .utf8) {
            FileHandle.standardError.write(data)
        }

        // file
        if let logFileHandle = logFileHandle, let data = fileMessage.data(using: .utf8) {
            logFileHandle.write(data)
        }
    }

    public func debug(_ message: String, file: String = #file, line: Int = #line) {
        write(level: .debug, file: file, line: line, message: message)
    }

    public func info(_ message: String, file: String = #file, line: Int = #line) {
        write(level: .info, file: file, line: line, message: message)
    }

    public func warn(_ message: String, file: String = #file, line: Int = #line) {
        write(level: .warn, file: file, line: line, message: message)
    }

    public func error(_ message: String, file: String = #file, line: Int = #line) {
        write(level: .error, file: file, line: line, message: message)
    }
}

// Global macros parity (as functions)
public func LOG_DEBUG(_ message: String, file: String = #file, line: Int = #line) {
    Logger.shared.debug(message, file: file, line: line)
}

public func LOG_INFO(_ message: String, file: String = #file, line: Int = #line) {
    Logger.shared.info(message, file: file, line: line)
}

public func LOG_WARN(_ message: String, file: String = #file, line: Int = #line) {
    Logger.shared.warn(message, file: file, line: line)
}

public func LOG_ERROR(_ message: String, file: String = #file, line: Int = #line) {
    Logger.shared.error(message, file: file, line: line)
}
