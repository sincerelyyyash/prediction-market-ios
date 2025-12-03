import Foundation

struct SignUpRequest: Encodable {
    let name: String
    let email: String
    let password: String
}

struct SignUpResponse: Decodable {
    let status: String
    let message: String
    let token: String
    let user: AuthenticatedUser
}

