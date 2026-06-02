import XCTest
@testable import NTRIP

final class LoggerTests: XCTestCase {
    func testLoggerInitializationAndWrite() {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("test_logs").path
        
        // Clean up before test
        try? FileManager.default.removeItem(atPath: tempDir)
        
        let success = Logger.shared.initialize(logDirectory: tempDir, appName: "testapp")
        XCTAssertTrue(success, "Logger should initialize successfully")
        
        Logger.shared.logLevel = .debug
        Logger.shared.info("Test info message")
        Logger.shared.debug("Test debug message")
        Logger.shared.close()
        
        // Verify file was created
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: tempDir) else {
            XCTFail("Log directory not created")
            return
        }
        XCTAssertTrue(files.count > 0, "Log file should be created")
        
        let logFile = files.first(where: { $0.starts(with: "testapp_") })
        XCTAssertNotNil(logFile, "App prefixed log file should exist")
        
        if let logFile = logFile {
            let content = try? String(contentsOfFile: tempDir + "/" + logFile)
            XCTAssertNotNil(content)
            XCTAssertTrue(content!.contains("Test info message"))
            XCTAssertTrue(content!.contains("Test debug message"))
        }
    }
}
