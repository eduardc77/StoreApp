//
//  AccountService.swift
//  Store
//

import Foundation

public protocol AccountServiceProtocol {
    func login<T: Decodable>(with credentials: Credentials) async throws -> T
    func profile<T: Decodable>() async throws -> T
    func invalidateToken() async
    func isAccessTokenValid() async throws -> Bool
    func storeToken(loginResponseData: LoginResponseData) async
}

public struct AccountService: AccountServiceProtocol {

    private let client: any APIClient
    private let authorizationManager: AuthorizationManager

    public init() {
        self.authorizationManager = AuthorizationManager()
        self.client = StoreClient(authorizationManager: authorizationManager)
    }

    public func login<T: Decodable>(with credentials: Credentials) async throws -> T {
        try await client.request(
            Store.Authentication.login(credentials: credentials),
            in: Store.Environment.develop)
    }

    public func profile<T: Decodable>() async throws -> T {
        try await client.authorizedRequest(
            Store.Authentication.profile,
            in: Store.Environment.develop)
    }

    public func isAccessTokenValid() async throws -> Bool {
        let authorizationdata = try await authorizationManager.validToken()
        return authorizationdata.isAccessTokenValid
    }

    public func invalidateToken() async {
        await authorizationManager.invalidateToken()
    }

    public func storeToken(loginResponseData: LoginResponseData) async {
        await authorizationManager.storeToken(
            OAuthTokenDTO(
                accessToken: loginResponseData.accessToken,
                refreshToken: loginResponseData.refreshToken,
                expiryDate: Date().addingTimeInterval(2 * 60) // Mocked 2 minutes
            )
        )
    }
}
