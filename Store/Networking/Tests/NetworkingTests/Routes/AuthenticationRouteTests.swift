@testable import Networking
import Testing
import Foundation

@Suite("Authentication Route Tests")
struct AuthenticationRouteTests {

    @Test("Login route constructs valid form data")
    func testLoginRoute() throws {
        // Given
        let credentials = Credentials(email: "test@example.com", password: "password123")
        let route = Store.Authentication.login(credentials: credentials)
        let env = Store.Environment.develop

        // When
        let request = try route.urlRequest(for: env)

        // Debug logging
        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            print("Request body: \(bodyString)")
        }

        // Then
        #expect(request.httpMethod == "POST")
        #expect(request.url?.absoluteString == "https://api.escuelajs.co/api/v1/auth/login")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == ContentType.form.rawValue)

        let body = request.httpBody.flatMap { String(data: $0, encoding: .utf8) }
        #expect(body?.contains("email=test@example.com".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") == true)
        #expect(body?.contains("password=password123") == true)
    }

    @Test("Profile route requires authorization")
    func testProfileRoute() throws {
        // Given
        let route = Store.Authentication.profile
        let token = OAuthTokenDTO.mock()
        let env = Store.Environment.develop

        // When
        let request = try route.urlRequest(for: env, token: token)

        // Then
        #expect(request.httpMethod == "GET")
        #expect(request.url?.absoluteString == "https://api.escuelajs.co/api/v1/auth/profile")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer \(token.accessToken)")
    }

    @Test("Refresh token route constructs valid request")
    func testRefreshTokenRoute() throws {
        // Given
        let route = Store.Authentication.refreshToken(refreshToken: "test-token")
        let env = Store.Environment.develop

        // When
        let request = try route.urlRequest(for: env)

        // Then
        #expect(request.httpMethod == "POST")
        #expect(request.url?.absoluteString == "https://api.escuelajs.co/api/v1/auth/refresh-token")

        let body = request.httpBody.flatMap { String(data: $0, encoding: .utf8) }
        #expect(body?.contains("refreshToken=test-token") == true)
    }

    @Test("Invalid URL components throw error")
    func testInvalidURLThrows() async throws {
        // Given
        struct MockEnvironment: APIEnvironment {
            var scheme: String = "http"
            var host: String = " "
            var apiVersion: APIVersion? = nil
            var domain: String = " "
            var headers: [String : String]? = nil
            var queryParams: [String : String]? = nil
        }
        let invalidEnv = MockEnvironment()
        let route = MockRoute.mock()
        // When/Then
        var errorThrown = false
        do {
            _ = try route.urlRequest(for: invalidEnv)
        } catch {
            errorThrown = true
            guard let networkError = error as? NetworkError,
                  case .invalidURLInComponents = networkError else {
                #expect(Bool(false), "Expected NetworkError.invalidURLInComponents, got \(error)")
                return
            }
        }
        #expect(errorThrown, "Expected NetworkError.invalidURLInComponents to be thrown")
    }
}


struct MockRoute: APIRoute {
    let httpMethod: HTTPMethod
    let path: String
    let formParams: [String: String]?
    let queryParams: [String: String]?
    let headers: [String: String]?
    let uploadData: Data?
    let mockFile: String?

    init(
        httpMethod: HTTPMethod = .get,
        path: String = "/test",
        formParams: [String: String]? = nil,
        queryParams: [String: String]? = nil,
        headers: [String: String]? = nil,
        uploadData: Data? = nil,
        mockFile: String? = nil
    ) {
        self.httpMethod = httpMethod
        self.path = path
        self.formParams = formParams
        self.queryParams = queryParams
        self.headers = headers
        self.uploadData = uploadData
        self.mockFile = mockFile
    }
}

extension MockRoute {
    static func mock(
        method: HTTPMethod = .get,
        path: String = "/test"
    ) -> MockRoute {
        MockRoute(
            httpMethod: method,
            path: path
        )
    }
}
