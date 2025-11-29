import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct RequestBuilder {
    private let baseURL: URL

    init(baseURL: URL = APIConfiguration.shared.baseURL) {
        self.baseURL = baseURL
    }

    func build(
        path: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem]? = nil,
        body: Data? = nil,
        additionalHeaders: [String: String] = [:]
    ) throws -> URLRequest {
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        ) else {
            throw APIError.invalidURL
        }

        if let queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url, timeoutInterval: APIConfiguration.shared.requestTimeout)
        request.httpMethod = method.rawValue
        request.httpBody = body

        var headers: [String: String] = [
            "Accept": "application/json"
        ]
        if body != nil {
            headers["Content-Type"] = "application/json"
        }

        additionalHeaders.forEach { headers[$0.key] = $0.value }
        request.allHTTPHeaderFields = headers

        return request
    }
}

