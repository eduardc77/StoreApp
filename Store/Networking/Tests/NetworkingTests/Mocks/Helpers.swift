@testable import Networking
import Foundation

func makeTestClient() -> (StoreClient, MockTokenStore) {
    let session = URLSession(configuration: .mockConfig())
    let tokenStore = MockTokenStore()
    let authManager = AuthorizationManager(tokenStore: tokenStore)
    let client = StoreClient(
        authorizationManager: authManager,
        dataLoader: session
    )
    return (client, tokenStore)
}

extension URLSessionConfiguration {
    static func mockConfig() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return config
    }
}

func makeTestResponse<T: Encodable>(
    data: T,
    statusCode: Int = 200,
    path: String
) async throws -> (Data, URLResponse) {
    let fullPath = "/api/v1\(path)"
    return (
        try JSONEncoder().encode(data),
        HTTPURLResponse(
            url: URL(string: "https://api.escuelajs.co\(fullPath)")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    )
}
