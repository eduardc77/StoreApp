//
//  RegisterFormData.swift
//  Store
//

public struct RegisterFormData: Decodable {
    public var name: String
    public var email: String
    public var password: String
    public var avatar: String
    
    public init(name: String, email: String, password: String, avatar: String) {
        self.name = name
        self.email = email
        self.password = password
        self.avatar = avatar
    }
}
