import Foundation

struct UserProfile: Decodable, Identifiable, Equatable {
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

    init(id: UInt64, email: String, name: String, balance: Int64?) {
        self.id = id
        self.email = email
        self.name = name
        self.balance = balance
    }
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

