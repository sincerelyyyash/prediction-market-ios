import Foundation

struct SignUpRequest: Encodable {
    let name: String
    let email: String
    let password: String
}

struct SignUpResponse: Decodable {
    let status: String
    let message: String
    let userId: UInt64

    private enum CodingKeys: String, CodingKey {
        case status
        case message
        case userId = "user_id"
    }
}

