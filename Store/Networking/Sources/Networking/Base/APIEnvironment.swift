//
//  APIEnvironment.swift
//  Store
//

public protocol APIEnvironment: APIRequestData, Sendable {
    var scheme: String { get }
    var host: String { get }
    var apiVersion: APIVersion? { get }
    var domain: String { get }
}

extension APIEnvironment {
    // Default  Values
    public var scheme: String { "https" }
    public var host: String { "" }
    public var apiVersion: APIVersion? { nil }
    public var domain: String { "" }
}
