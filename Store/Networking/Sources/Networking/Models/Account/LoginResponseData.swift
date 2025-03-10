//
//  LoginResponseData.swift
//  Store
//

public struct LoginResponseData: Codable {
    public let refreshToken: String
    public let accessToken: String

    public init(refreshToken: String, accessToken: String) {
        self.refreshToken = refreshToken
        self.accessToken = accessToken
    }
}

extension LoginResponseData: Sendable {}
