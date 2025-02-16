//
//  AuthorizationManager.swift
//  Store
//

import Foundation.NSDate

actor AuthorizationManager {

    private var refreshTask: Task<OAuthToken, Error>?
    let session: URLSession
    let tokenStore: TokenStoreProtocol

    var hasValidAccessToken: Bool {
        guard let accessToken = tokenStore.getAuthorizationData() else { return false }
        return accessToken.isAccessTokenValid
    }

    init(tokenStore: TokenStoreProtocol = TokenStore(),
         session: URLSession) {
        self.tokenStore = tokenStore
        self.session = session
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
        guard let refreshToken = tokenStore.getAuthorizationData()?.refreshToken else {
            throw NetworkError.missingToken
            // throw AuthorizationError.failed
        }
        let refreshTask = Task { () throws -> OAuthToken in
            defer { self.refreshTask = nil }

            var authorizationData: OAuthToken = try await session.authorizedRequest(
                (route: Store.Authentication.refreshToken(refreshToken: refreshToken),
                 env: Store.Environment.develop()),
                allowRetry: true,
                refreshToken: self.refreshToken
            )
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
