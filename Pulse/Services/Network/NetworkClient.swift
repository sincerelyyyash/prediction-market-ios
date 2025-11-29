import Foundation

protocol AccessTokenProviding: AnyObject {
    var accessToken: String? { get }
}

struct EmptyResponse: Decodable {}

final class NetworkClient {
    static let shared = NetworkClient()

    weak var tokenProvider: AccessTokenProviding?

    private let session: URLSession
    private let requestBuilder: RequestBuilder
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(
        session: URLSession = .shared,
        requestBuilder: RequestBuilder = RequestBuilder(),
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder(),
        tokenProvider: AccessTokenProviding? = nil
    ) {
        self.session = session
        self.requestBuilder = requestBuilder
        self.decoder = decoder
        self.encoder = encoder
        self.tokenProvider = tokenProvider
    }

    func send<Response: Decodable>(
        path: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem]? = nil,
        body: Data? = nil,
        additionalHeaders: [String: String] = [:],
        requiresAuth: Bool = false
    ) async throws -> Response {
        var headers = additionalHeaders
        if requiresAuth {
            guard let token = tokenProvider?.accessToken, !token.isEmpty else {
                throw APIError.authenticationRequired
            }
            headers["Authorization"] = "Bearer \(token)"
        }

        let request = try requestBuilder.build(
            path: path,
            method: method,
            queryItems: queryItems,
            body: body,
            additionalHeaders: headers
        )

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.network(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            if httpResponse.statusCode == 401 {
                throw APIError.authenticationRequired
            }
            let message = parseErrorMessage(from: data)
            throw APIError.server(statusCode: httpResponse.statusCode, message: message)
        }

        if Response.self == EmptyResponse.self, data.isEmpty {
            return EmptyResponse() as! Response
        }

        guard !data.isEmpty else {
            throw APIError.decoding(NSError(domain: "Empty data", code: -1))
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    func send<Response: Decodable, Body: Encodable>(
        path: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem]? = nil,
        body: Body,
        additionalHeaders: [String: String] = [:],
        requiresAuth: Bool = false
    ) async throws -> Response {
        let encodedBody: Data
        do {
            encodedBody = try encoder.encode(body)
        } catch {
            throw APIError.network(error)
        }
        return try await send(
            path: path,
            method: method,
            queryItems: queryItems,
            body: encodedBody,
            additionalHeaders: additionalHeaders,
            requiresAuth: requiresAuth
        )
    }

    private func parseErrorMessage(from data: Data) -> String? {
        guard !data.isEmpty else { return nil }
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let message = json["message"] as? String {
                return message
            }
            if let status = json["status"] as? String {
                return status
            }
        }
        return String(data: data, encoding: .utf8)
    }
}

