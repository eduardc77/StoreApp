//
//  User.swift
//  Store
//

public struct User: Identifiable, Decodable {
    public let id: Int
    public let name: String
    public let email: String
    public let password: String
    public let avatar: String
    public let role: String
    public let creationAt: String?
    public let updatedAt: String?
    
    public init(id: Int, name: String, email: String, password: String, avatar: String, role: String, creationAt: String?, updatedAt: String?) {
        self.id = id
        self.name = name
        self.email = email
        self.password = password
        self.avatar = avatar
        self.role = role
        self.creationAt = creationAt
        self.updatedAt = updatedAt
    }
}
