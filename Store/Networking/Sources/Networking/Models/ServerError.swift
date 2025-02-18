//
//  ServerError.swift
//  Store
//

struct ServerError: Codable {
    let error: String
    let timestamp: String
    let path: String
    let status: Int
    
    enum CodingKeys: String, CodingKey {
        case error
        case timestamp
        case status
        case path
    }
}
