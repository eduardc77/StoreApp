@testable import Networking
import Testing
import Foundation

@Suite("Authorization Manager Tests")
struct AuthorizationManagerTests {

    @Test("Valid token is returned when not expired")
    func testValidToken() async throws {
        let tokenStore = MockTokenStore()
        let authManager = AuthorizationManager(tokenStore: tokenStore)

        let validToken = OAuthTokenDTO.mock()
        await authManager.storeToken(validToken)

        let result = try await authManager.validToken()
        #expect(result.accessToken == validToken.accessToken)
        #expect(result.isAccessTokenValid == true)
    }

    @Test("Token refresh is triggered when expired")
    func testTokenRefresh() async throws {
        let tokenStore = MockTokenStore()
        let session = URLSession(configuration: .mockConfig())
        let refreshService = RefreshTokenNetworkService(dataloader: session)
        let authManager = AuthorizationManager(
            refreshTokenNetworkService: refreshService,
            tokenStore: tokenStore
        )

        let expiredToken = OAuthTokenDTO.mock(
            expiryDate: Date().addingTimeInterval(-3600)
        )
        await authManager.storeToken(expiredToken)

        let state = await MockURLProtocol.state
        let refreshedToken = OAuthTokenDTO.mock(accessToken: "new-token")
        await state.setMockResponse(
            try await makeTestResponse(data: refreshedToken, path: "/auth/refresh-token"),
            for: "/api/v1/auth/refresh-token"
        )

        let result = try await authManager.validToken()
        #expect(result.accessToken == refreshedToken.accessToken)
    }
}
