//
//  Credentials.swift
//  Store
//

public struct Credentials: Decodable {
    public var email: String
    public var password: String
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}
