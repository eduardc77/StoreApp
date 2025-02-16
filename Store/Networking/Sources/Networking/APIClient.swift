//
//  APIClient.swift
//  Store
//

import Foundation
import OSLog

extension URLSession: APIClient {
    
    func request<T: Decodable>(
        _ request: (route: APIRoute, env: APIEnvironment),
        decoder: JSONDecoder? = nil,
        allowRetry: Bool = true
    ) async throws -> T {
        try await self.fetchRequest((route: request.route, env: request.env), decoder: decoder, allowRetry: allowRetry)
    }
    
    func authorizedRequest<T: Decodable>(
        _ request: (route: APIRoute, env: APIEnvironment),
        decoder: JSONDecoder? = nil,
        allowRetry: Bool,
        refreshToken: (() async throws -> OAuthToken)?
    ) async throws -> T {
        try await self.fetchRequest(
            (route: request.route, env: request.env),
            decoder: decoder,
            allowRetry: allowRetry,
            refreshToken: refreshToken)
    }
}

public protocol APIClient {
    
    /// Fetch data with the provided `URLRequest`.
    func data(
        for request: URLRequest
    ) async throws -> (Data, URLResponse)
}

extension APIClient {
    
    public func fetchRequest<T: Decodable>(
        _ request: (route: APIRoute, env: APIEnvironment),
        decoder: JSONDecoder? = nil,
        allowRetry: Bool,
        refreshToken: (() async throws -> OAuthToken)? = nil
    ) async throws -> T {
        let (data, response) = try await data(for: request.route.urlRequest(for: request.env))
        
        return try await handleResponse(
            requestResponse: (data: data, response: response),
            request: (route: request.route, env: request.env),
            decoder: decoder,
            allowRetry: allowRetry,
            refreshToken: refreshToken
        )
    }
    
    private func handleResponse<T: Decodable>(
        requestResponse: (data: Data, response: URLResponse),
        request: (route: APIRoute, env: APIEnvironment),
        decoder: JSONDecoder? = nil,
        allowRetry: Bool,
        refreshToken: (() async throws -> OAuthToken)?
    ) async throws -> T {
        guard let httpResponse = requestResponse.response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decoder = decoder ?? JSONDecoder()
                return try decoder.decode(T.self, from: requestResponse.data)
            } catch {
                throw NetworkError.decodingError
            }
        case 401, 403:
            // Unauthorized or Forbidden (likely token expired), attempt to refresh token and retry request once.
            return try await refreshTokenAndRetryRequestOnce(
                request: (route: request.route, env: request.env),
                decoder: decoder,
                allowRetry: allowRetry,
                refreshToken: refreshToken)
        case 400...499:
            if let error = try? JSONDecoder().decode(ServerError.self, from: requestResponse.data) {
                throw NetworkError.internalServerError(message: error.error)
            } else {
                throw NetworkError.invalidResponse
            }
        case 500...599:
            throw NetworkError.requestFailed(statusCode: httpResponse.statusCode, message: httpResponse.description)
        default:
            throw NetworkError.invalidResponse
        }
    }
    
    func refreshTokenAndRetryRequestOnce<T: Decodable>(
        request: (route: APIRoute, env: APIEnvironment),
        decoder: JSONDecoder? = nil,
        allowRetry: Bool,
        refreshToken: (() async throws -> OAuthToken)?
    ) async throws -> T {
        if allowRetry {
            _ = try await refreshToken?()
            return try await self.fetchRequest(
                request,
                decoder: decoder,
                allowRetry: allowRetry,
                refreshToken: refreshToken)
        } else {
            throw NetworkError.unauthorized
        }
    }
}
// if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
//    let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
//     print(String(decoding: jsonData, as: UTF8.self))
// } else {
//     print("json data malformed")
// }
