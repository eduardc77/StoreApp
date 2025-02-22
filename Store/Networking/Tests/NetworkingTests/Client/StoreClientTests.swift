@testable import Networking
import Testing
import Foundation

@Suite("Store Client Tests")
struct StoreClientTests {

    func setUp() async {
        await MockURLProtocol.reset()
        URLProtocol.registerClass(MockURLProtocol.self)
    }

    func tearDown() async {
        await MockURLProtocol.reset()
        URLProtocol.unregisterClass(MockURLProtocol.self)
    }

    @Test("Basic request succeeds")
    func testBasicRequest() async throws {
        let (client, _) = makeTestClient()
        let mockUser = User.mock()

        let state = await MockURLProtocol.state
        await state.setMockResponse(
            try await makeTestResponse(data: mockUser, path: "/users"),
            for: "/api/v1/users"
        )

        let result: User = try await client.request(
            Store.Users.createUser(registerFormData: .init(
                name: "Test",
                email: "test@example.com",
                password: "password",
                avatar: "avatar.jpg"
            )),
            in: Store.Environment.develop
        )

        #expect(result.id == mockUser.id)
        #expect(result.name == mockUser.name)
    }

    @Test("Authorized request includes token")
    func testAuthorizedRequest() async throws {
        // Given
        let state = await MockURLProtocol.state
        let (client, tokenStore) = makeTestClient()
        let mockUser = User.mock()

        // Create and verify token
        let token = OAuthTokenDTO.mock()
        await client.authorizationManager.storeToken(token)

        let storedToken = await tokenStore.getAuthorizationData()
        print("Token stored: \(String(describing: storedToken?.accessToken))")
        #expect(storedToken?.accessToken == "test-token")

        // Set up response
        print("Setting mock response")
        await state.setMockResponse(
            try await makeTestResponse(data: mockUser, path: "/auth/profile"),
            for: "/api/v1/auth/profile"
        )

        // When - Make request
        print("Making authorized request")
        let _: User = try await client.authorizedRequest(
            Store.Authentication.profile,
            in: Store.Environment.develop,
            allowRetry: false
        )

        // Then - Get captured request immediately
        let request = await state.getLastRequest()
        print("Captured request: \(String(describing: request?.url))")
        print("Request headers: \(String(describing: request?.allHTTPHeaderFields))")

        let authHeader = request?.value(forHTTPHeaderField: "Authorization")
        #expect(authHeader == "Bearer test-token")
    }
}
