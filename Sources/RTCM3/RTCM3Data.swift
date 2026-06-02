import Foundation

public struct GNSSConstants {
    public static let numRTCM3ParserSats = 144
    public static let gnssMaxSats = 64
    
    public static let prnGPSStart = 1
    public static let prnGPSEnd = 32
    public static let prnGlonassStart = 38
    public static let prnGlonassEnd = 61
    public static let prnGalileoStart = 71
    public static let prnGalileoEnd = 100
    public static let prnGioveStart = 101
    public static let prnGioveEnd = 102
    public static let prnSbasStart = 120
    public static let prnSbasEnd = 141
    public static let prnBdsStart = 161
    public static let prnBdsEnd = 190
    public static let prnQzssStart = 193
    public static let prnQzssEnd = 202
}

public struct RTCM3Data {
    public var flags: Int = 0
    public var week: Int = 0
    public var numSats: Int = 0
    public var timeOfWeek: Double = 0.0
    public var measData: [[Double]] = Array(repeating: Array(repeating: 0.0, count: 40), count: GNSSConstants.gnssMaxSats)
    public var dataFlags: [UInt64] = Array(repeating: 0, count: GNSSConstants.gnssMaxSats)
    public var dataFlags2: [UInt32] = Array(repeating: 0, count: GNSSConstants.gnssMaxSats)
    public var satellites: [Int] = Array(repeating: 0, count: GNSSConstants.gnssMaxSats)
    public var snrL1: [Int] = Array(repeating: 0, count: GNSSConstants.gnssMaxSats)
    public var snrL2: [Int] = Array(repeating: 0, count: GNSSConstants.gnssMaxSats)
    public var codeType: [[String?]] = Array(repeating: Array(repeating: nil, count: 40), count: GNSSConstants.gnssMaxSats)

    public init() {}
}

public struct GPSEphemeris {
    public var flags: Int = 0
    public var satellite: Int = 0
    public var iode: Int = 0
    public var uraIndex: Int = 0
    public var svHealth: Int = 0
    public var gpsWeek: Int = 0
    public var iodc: Int = 0
    public var tow: Int = 0
    public var toc: Int = 0
    public var toe: Int = 0
    public var clockBias: Double = 0.0
    public var clockDrift: Double = 0.0
    public var clockDriftRate: Double = 0.0
    public var crs: Double = 0.0
    public var deltaN: Double = 0.0
    public var m0: Double = 0.0
    public var cuc: Double = 0.0
    public var e: Double = 0.0
    public var cus: Double = 0.0
    public var sqrtA: Double = 0.0
    public var cic: Double = 0.0
    public var omega0: Double = 0.0
    public var cis: Double = 0.0
    public var i0: Double = 0.0
    public var crc: Double = 0.0
    public var omega: Double = 0.0
    public var omegaDot: Double = 0.0
    public var idot: Double = 0.0
    public var tgd: Double = 0.0

    public init() {}
}

public struct SystemBitCounts {
    public static let df001 = 4
}

// Add other ephemeris types as needed (Glonass, Galileo, BDS, SBAS)
