//
//  UsersService.swift
//  Store
//

import Foundation

public protocol UsersServiceProtocol {
    func register<T: Decodable & Sendable>(with registerFormData: RegisterFormData) async throws -> T
    func isEmailAvailable<T: Decodable & Sendable>(_ email: String) async throws -> T
    func updateUser<T: Decodable & Sendable>(with id: Int, name: String, email: String) async throws -> T
}

public struct UsersService: UsersServiceProtocol {

    private let client: any APIClient
    private let authorizationManager: AuthorizationManager

    public init(
        client: any APIClient = StoreClient(authorizationManager: AuthorizationManager()),
        authorizationManager: AuthorizationManager = AuthorizationManager()
    ) {
        self.client = client
        self.authorizationManager = authorizationManager
    }

    public func register<T: Decodable & Sendable>(with registerFormData: RegisterFormData) async throws -> T {
        try await client.request(
            Store.Users.createUser(registerFormData: registerFormData),
            in: Store.Environment.develop)
    }

    public func isEmailAvailable<T: Decodable & Sendable>(_ email: String) async throws -> T {
        try await client.request(
            Store.Users.isEmailAvailable(email),
            in: Store.Environment.develop)
    }

    public func updateUser<T: Decodable & Sendable>(with id: Int, name: String, email: String) async throws -> T {
        try await client.request(
            Store.Users.updateUser(id: id, name: name, email: email),
            in: Store.Environment.develop)
    }
}

//protocol UsersService {
//    private func configureSession(timeoutInterval: TimeInterval) {
//        session.configuration.timeoutIntervalForRequest = timeoutInterval
//        session.configuration.timeoutIntervalForResource = timeoutInterval
//        session.configuration.urlCache = cacheManager.urlCache
//    }
//}
//
