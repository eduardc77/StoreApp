//
//  OAuthToken.swift
//  Store
//

import Foundation

public protocol OAuthToken: Codable, Sendable {
    var accessToken: String? { get }
    var refreshToken: String?{ get }
    var expiryDate: Date? { get set }
    var isAccessTokenValid: Bool { get }
}

public struct OAuthTokenDTO: OAuthToken {
    public var accessToken: String?
    public var refreshToken: String?
    public var expiryDate: Date?
    
    public var isAccessTokenValid: Bool {
        guard let expiryDate else { return false }
        return expiryDate > Date()
    }
    
    public init(accessToken: String?, refreshToken: String?, expiryDate: Date? = nil) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiryDate = expiryDate
    }
}

/**
 Enum for Token Types
 */
public enum TokenType: String {
    case bearer = "Bearer"
}
