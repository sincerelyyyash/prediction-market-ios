import Foundation

struct APIEnvelope<T: Decodable>: Decodable {
    let status: String?
    let message: String?
    let data: T?

    func requireData() throws -> T {
        guard let data else {
            throw APIError.decoding(NSError(domain: "APIEnvelope", code: -1))
        }
        return data
    }
}

