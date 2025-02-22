//
//  APIRequestData.swift
//  Store
//

import Foundation.NSURL

public protocol APIRequestData: Sendable {
    
    /// Optional header parameters.
    var headers: [String: String]? { get }
    
    /// Optional query params.
    var queryParams: [String: String]? { get }
}

extension APIRequestData {
    
    /// Convert ``queryParams`` to url encoded query items.
    var encodedQueryItems: [URLQueryItem]? {
        queryParams?
            .map { URLQueryItem(name: $0.key, value: $0.value) }
            .sorted { $0.name < $1.name }
    }
    
    /// Default value.
    var headers: [String: String]? { return nil }
    
    /// Default value.
    var queryParams: [String: String]? { return nil }
}
