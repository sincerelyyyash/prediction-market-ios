import Foundation

struct AuthenticatedUser: Decodable, Equatable {
    let id: UInt64
    let email: String
    let name: String
    let balance: Int64?
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

