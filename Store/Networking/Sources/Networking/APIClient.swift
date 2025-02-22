//
//  APIClient.swift
//  Store
//

import Foundation
import OSLog

public protocol HTTPDataLoader: Sendable {

    /// Fetch data with the provided `URLRequest`.
    func data(
        from route: APIRoute,
        in environment: APIEnvironment,
        token: OAuthToken?
    ) async throws -> (Data, URLResponse)
}

extension HTTPDataLoader {

    func data(from route: APIRoute,
              in environment: APIEnvironment,
              token: OAuthToken? = nil
    ) async throws -> (Data, URLResponse) {
        try await data(
            from: route,
            in: environment,
            token: token
        )
    }
}

extension URLSession: HTTPDataLoader {

    public func data(
        from route: APIRoute,
        in environment: APIEnvironment,
        token: OAuthToken? = nil
    ) async throws -> (Data, URLResponse) {
        try await data(for: route.urlRequest(
            for: environment,
            token: token)
        )
    }
}

public protocol APIClient: Sendable {

    func request<T: Decodable & Sendable>(
        _ route: APIRoute,
        in: APIEnvironment
    ) async throws -> T

    func authorizedRequest<T: Decodable & Sendable>(
        _ route: APIRoute,
        in: APIEnvironment,
        allowRetry: Bool
    ) async throws -> T
}

extension APIClient {

    public func request<T: Decodable & Sendable>(
        _ route: APIRoute,
        in environment: APIEnvironment
    ) async throws -> T {
        try await self.request(route, in: environment)
    }

    public func authorizedRequest<T: Decodable & Sendable>(
        _ route: APIRoute,
        in environment: APIEnvironment,
        allowRetry: Bool = true
    ) async throws -> T {
        try await authorizedRequest(
            route,
            in: environment,
            allowRetry: allowRetry)
    }
}
