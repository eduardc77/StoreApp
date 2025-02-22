@testable import Networking
import Testing
import Foundation

@Suite("Account Service Tests")
struct AccountServiceTests {

    func setUp() async {
        await MockURLProtocol.reset()
        URLProtocol.registerClass(MockURLProtocol.self)
    }

    func tearDown() async {
        URLProtocol.unregisterClass(MockURLProtocol.self)
    }

    @Test("Login succeeds")
    func testLogin() async throws {
        let (client, _) = makeTestClient()
        let service = AccountService(client: client)

        let mockResponse = LoginResponseData(
            refreshToken: "refresh-token",
            accessToken: "access-token"
        )

        let state = await MockURLProtocol.state
        await state.setMockResponse(
            try await makeTestResponse(data: mockResponse, path: "/auth/login"),
            for: "/api/v1/auth/login"
        )

        let credentials = Credentials(email: "test@example.com", password: "password123")
        let result: LoginResponseData = try await service.login(with: credentials)

        #expect(result.accessToken == mockResponse.accessToken)
        #expect(result.refreshToken == mockResponse.refreshToken)
    }

    @Test("Profile fetch succeeds")
    func testProfile() async throws {
        let (client, _) = makeTestClient()
        let service = AccountService(client: client)

        let mockUser = User.mock()
        let token = OAuthTokenDTO.mock()

        await client.authorizationManager.storeToken(token)

        let state = await MockURLProtocol.state
        await state.setMockResponse(
            try await makeTestResponse(data: mockUser, path: "/auth/profile"),
            for: "/api/v1/auth/profile"
        )

        let result: User = try await service.profile()

        #expect(result.id == mockUser.id)
        #expect(result.name == mockUser.name)
    }
}
