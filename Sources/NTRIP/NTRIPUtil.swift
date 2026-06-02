import Foundation

public struct NTRIPUtil {
    /// Encodes a username and password into a Base64 string for Basic Authentication.
    /// Matches the behavior of `ntrip_encode_base64` in C.
    public static func encodeBase64(user: String, password: String) -> String {
        let authString = "\(user):\(password)"
        guard let data = authString.data(using: .utf8) else {
            return ""
        }
        return data.base64EncodedString()
    }
}
