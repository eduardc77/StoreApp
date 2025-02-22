//
//  OAuthToken.swift
//  Store
//

import Foundation

public protocol OAuthToken: Sendable, Codable {
    var accessToken: String { get }
    var refreshToken: String { get }
    var expiryDate: Date? { get set }
    var isAccessTokenValid: Bool { get }
}

public struct OAuthTokenDTO: OAuthToken {
    public let accessToken: String
    public let refreshToken: String
    public var expiryDate: Date?
    
    public init(accessToken: String, refreshToken: String, expiryDate: Date? = nil) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiryDate = expiryDate
    }
    
    public var isAccessTokenValid: Bool {
        guard let expiryDate else { return false }
        return expiryDate > Date()
    }
}

/**
 Enum for Token Types
 */
public enum TokenType: String {
    case bearer = "Bearer"
}
