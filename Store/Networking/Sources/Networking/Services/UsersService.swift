//
//  UsersService.swift
//  Store
//

import Foundation

public protocol UsersServiceProtocol {
    func register<T: Decodable>(with registerFormData: RegisterFormData) async throws -> T
    func isEmailAvailable<T: Decodable>(_ email: String) async throws -> T
    func updateUser<T: Decodable>(with id: Int, name: String, email: String) async throws -> T
}

public struct UsersService: UsersServiceProtocol {
    
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
    
    public func register<T: Decodable>(with registerFormData: RegisterFormData) async throws -> T {
        try await session.request(
            (route: Store.Users.createUser(registerFormData: registerFormData),
             env: Store.Environment.develop()),
            decoder: decoder
        )
    }
    
    public func isEmailAvailable<T: Decodable>(_ email: String) async throws -> T {
        try await session.request(
            (route: Store.Users.isEmailAvailable(email),
             env: Store.Environment.develop()),
            decoder: decoder
        )
    }
    
    public func updateUser<T: Decodable>(with id: Int, name: String, email: String) async throws -> T {
        try await session.request(
            (route: Store.Users.updateUser(id: id, name: name, email: email),
             env: Store.Environment.develop()),
            decoder: decoder
        )
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
