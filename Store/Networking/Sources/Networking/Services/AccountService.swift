//
//  AccountService.swift
//  Store
//

import Foundation

public protocol AccountServiceProtocol {
    func login<T: Decodable>(with credentials: Credentials) async throws -> T
    func profile<T: Decodable>() async throws -> T
    func invalidateToken() async
    func hasValidAccessToken() async -> Bool
    func storeToken(loginResponseData: LoginResponseData) async
}

public struct AccountService: AccountServiceProtocol {

    private let session: URLSession
    private let authorizationManager: AuthorizationManager

    private var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    public init(session: URLSession = URLSession.shared) {
        self.session = session
        self.authorizationManager = AuthorizationManager(session: session)
    }

    public func login<T: Decodable>(with credentials: Credentials) async throws -> T {
        try await session.request(
            (route: Store.Authentication.login(credentials: credentials),
             env: Store.Environment.develop()),
            decoder: decoder
        )
    }

    public func profile<T: Decodable>() async throws -> T {
        try await session.authorizedRequest(
            (route: Store.Authentication.profile,
            env: Store.Environment.develop(accessToken: authorizationManager.validToken().accessToken)),
            decoder: decoder,
            allowRetry: true,
            refreshToken: authorizationManager.refreshToken
        )
    }

    public func hasValidAccessToken() async -> Bool {
        await authorizationManager.hasValidAccessToken
    }

    public func invalidateToken() async {
        await authorizationManager.invalidateToken()
    }

    public func storeToken(loginResponseData: LoginResponseData) async {
        await authorizationManager.storeToken(
            OAuthToken(
                accessToken: loginResponseData.accessToken,
                refreshToken: loginResponseData.refreshToken,
                expiryDate: Date().addingTimeInterval(2 * 60) // Mocked 2 minutes
            )
        )
    }
}
