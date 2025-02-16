//
//  RefreshTokenResponse.swift
//  Store
//

public struct RefreshTokenResponse: Decodable {
    public let accessToken: String
    
    public init(accessToken: String) {
        self.accessToken = accessToken
    }
}
