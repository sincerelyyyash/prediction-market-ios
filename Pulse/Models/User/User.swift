import Foundation

struct UserProfile: Decodable, Identifiable, Equatable {
    let id: UInt64
    let email: String
    let name: String
    let balance: Int64?
}

struct UserResponse: Decodable {
    let status: String?
    let message: String?
    let user: UserProfile?
}

struct BalanceResponse: Decodable {
    let status: String?
    let message: String?
    let balance: Int64?
}

struct OnrampRequest: Encodable {
    let amount: Int64
}

struct OnrampResponse: Decodable {
    let status: String?
    let message: String?
    let data: OnrampData?
}

struct OnrampData: Decodable {
    let userId: UInt64?
    let balance: Int64?

    private enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case balance
    }
}

