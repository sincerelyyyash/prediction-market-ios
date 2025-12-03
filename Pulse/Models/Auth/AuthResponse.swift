import Foundation

struct AuthenticatedUser: Decodable, Equatable {
    let id: UInt64
    let email: String
    let name: String
    let balance: Int64?
    private enum CodingKeys: String, CodingKey {
        case id, email, name, balance
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        email = try container.decode(String.self, forKey: .email)
        name = try container.decode(String.self, forKey: .name)
        balance = try container.decodeIfPresent(Int64.self, forKey: .balance)
        if let uint64Id = try? container.decode(UInt64.self, forKey: .id) {
            id = uint64Id
        } else if let int64Id = try? container.decode(Int64.self, forKey: .id), int64Id >= 0 {
            id = UInt64(int64Id)
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .id,
                in: container,
                debugDescription: "ID must be a non-negative Int64 or a UInt64"
            )
        }
    }
}

struct AuthResponse: Decodable {
    let status: String
    let message: String
    let token: String
    let user: AuthenticatedUser
}

struct AuthSession: Equatable {
    let token: String
    let user: AuthenticatedUser
}

