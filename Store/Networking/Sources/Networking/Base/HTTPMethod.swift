//
//  HTTPMethod.swift
//  Store
//

/**
 This enum defines various HTTP methods.
 */
enum HTTPMethod: String, CaseIterable, Identifiable {
    case connect
    case delete
    case get
    case head
    case options
    case patch
    case post
    case put
    case trace
    
    /// The unique HTTP method identifier.
    var id: String { rawValue }
    
    /// The uppercased HTTP method name.
    var method: String { id.uppercased() }
}
