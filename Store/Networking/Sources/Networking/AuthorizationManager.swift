//
//  AuthorizationManager.swift
//  Store
//

import Foundation.NSDate

actor AuthorizationManager {
    let refreshTokenNetworkService: RefreshTokenNetworkServicing
    let tokenStore: TokenStoreProtocol

    private var refreshTask: Task<OAuthToken, Error>?

    init(
        refreshTokenNetworkService: RefreshTokenNetworkServicing = RefreshTokenNetworkService(),
        tokenStore: TokenStoreProtocol = TokenStore()
    ) {
        self.refreshTokenNetworkService = refreshTokenNetworkService
        self.tokenStore = tokenStore
    }

    func validToken() async throws -> OAuthToken {
        if let refreshTask {
            // A refresh task is in progress.
            return try await refreshTask.value
        }
        guard let authorizationData = tokenStore.getAuthorizationData() else {
            throw NetworkError.missingToken
        }
        if authorizationData.isAccessTokenValid {
            return authorizationData
        }
        return try await refreshToken()
    }

    func refreshToken() async throws -> OAuthToken {
        if let refreshTask = refreshTask {
            // A refresh task is in progress.
            return try await refreshTask.value
        }
        guard let refreshToken = tokenStore.getAuthorizationData()?.refreshToken else {
            throw NetworkError.missingToken
            // throw AuthorizationError.failed
        }
        let refreshTask = Task { () throws -> OAuthToken in
            defer { self.refreshTask = nil }
            var authorizationData = try await refreshTokenNetworkService.refreshToken(refreshToken)
            if authorizationData.expiryDate == nil {
                let expiryDate = Date().addingTimeInterval(2 * 60) // Mocked 2 minutes
                authorizationData.expiryDate = expiryDate
            }
            tokenStore.setAuthorizationData(authorizationData)
            return authorizationData
        }
        self.refreshTask = refreshTask
        return try await refreshTask.value
    }

    func invalidateToken() {
        tokenStore.deleteAuthorizationData()
    }

    func storeToken(_ token: OAuthToken) {
        tokenStore.setAuthorizationData(token)
    }
}
