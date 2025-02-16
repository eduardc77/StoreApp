//
//  OAuthToken.swift
//  Store
//

import Foundation

public struct OAuthToken: Codable {
    public var accessToken: String
    public var refreshToken: String
    public var expiryDate: Date?
    
    public var isAccessTokenValid: Bool {
        guard let expiryDate else { return false }
        return expiryDate > Date()
    }
    
    public init(accessToken: String, refreshToken: String, expiryDate: Date? = nil) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiryDate = expiryDate
    }
}

extension OAuthToken: Sendable {}

/**
 Enum for Token Types
 */
public enum TokenType: String {
    case bearer = "Bearer"
}
