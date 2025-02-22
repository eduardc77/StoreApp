//
//  AuthorizationManager.swift
//  Store
//

import Foundation.NSDate

public actor AuthorizationManager {
    let refreshTokenNetworkService: RefreshTokenNetworkServicing
    let tokenStore: TokenStoreProtocol

    private var refreshTask: Task<OAuthToken, Error>?

    public init(
        refreshTokenNetworkService: RefreshTokenNetworkServicing = RefreshTokenNetworkService(),
        tokenStore: TokenStoreProtocol = TokenStore()
    ) {
        self.refreshTokenNetworkService = refreshTokenNetworkService
        self.tokenStore = tokenStore
    }

    public func validToken() async throws -> OAuthToken {
        if let refreshTask {
            // A refresh task is in progress.
            return try await refreshTask.value
        }
        guard let authorizationData = await tokenStore.getAuthorizationData() else {
            throw NetworkError.missingToken
        }
        if authorizationData.isAccessTokenValid {
            return authorizationData
        }
        return try await refreshToken()
    }

    public func refreshToken() async throws -> OAuthToken {
        if let refreshTask = refreshTask {
            // A refresh task is in progress.
            return try await refreshTask.value
        }
        guard let refreshToken = await tokenStore.getAuthorizationData()?.refreshToken else {
            throw NetworkError.missingToken
        }
        let refreshTask = Task { () throws -> OAuthToken in
            defer { self.refreshTask = nil }
            var authorizationData = try await refreshTokenNetworkService.refreshToken(refreshToken)
            if authorizationData.expiryDate == nil {
                let expiryDate = Date().addingTimeInterval(2 * 60) // Mocked 2 minutes
                authorizationData.expiryDate = expiryDate
            }
            await tokenStore.setAuthorizationData(authorizationData)
            return authorizationData
        }
        self.refreshTask = refreshTask
        return try await refreshTask.value
    }

    public func invalidateToken() async {
        await tokenStore.deleteAuthorizationData()
    }

    public func storeToken(_ token: OAuthToken) async {
        await tokenStore.setAuthorizationData(token)
    }

    // For testing purposes only
    #if DEBUG
    func hasActiveRefreshTask() -> Bool {
        refreshTask != nil
    }
    #endif
}
