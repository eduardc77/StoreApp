//
//  AccountService.swift
//  Store
//

import Foundation

public protocol AccountServiceProtocol {
    func login(with credentials: Credentials) async throws -> LoginResponseData
    func profile<T: Decodable & Sendable>() async throws -> T
    func invalidateToken() async
    func isAccessTokenValid() async throws -> Bool
    func storeToken(loginResponseData: LoginResponseData) async
}

public struct AccountService: AccountServiceProtocol {

    private let client: any APIClient
    private let authorizationManager: AuthorizationManager

    public init(
        client: any APIClient = StoreClient(authorizationManager: AuthorizationManager()),
        authorizationManager: AuthorizationManager = AuthorizationManager()
    ) {
        self.client = client
        self.authorizationManager = authorizationManager
    }

    public func login(with credentials: Credentials) async throws -> LoginResponseData {
        let response: LoginResponseData = try await client.request(
            Store.Authentication.login(credentials: credentials),
            in: Store.Environment.develop
        )
        await storeToken(loginResponseData: response)
        return response
    }

    public func profile<T: Decodable & Sendable>() async throws -> T {
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
        // Create token with future expiry to ensure it's valid
        let token = OAuthTokenDTO(
            accessToken: loginResponseData.accessToken,
            refreshToken: loginResponseData.refreshToken,
            expiryDate: Date().addingTimeInterval(3600) // Valid for 1 hour
        )
        
        // Store token
        await authorizationManager.storeToken(token)
    }
}
