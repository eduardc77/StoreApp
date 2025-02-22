//
//  StoreClient.swift
//  Networking
//

import Foundation
import OSLog

public final class StoreClient: APIClient {

    var decoder: JSONDecoder {
        let aDecoder = JSONDecoder()
        aDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return aDecoder
    }

    let authorizationManager: AuthorizationManager
    private let dataLoader: HTTPDataLoader

    public init(
        authorizationManager: AuthorizationManager,
        dataLoader: HTTPDataLoader = URLSession.shared
    ) {
        self.authorizationManager = authorizationManager
        self.dataLoader = dataLoader
    }

    public func request<T: Decodable & Sendable>(
        _ route: APIRoute,
        in environment: APIEnvironment
    ) async throws -> T {
        let (data, response) = try await dataLoader.data(from: route, in: environment)
        return try await handleResponse(
            requestResponse: (data: data, response: response),
            for: route,
            in: environment,
            allowRetry: false
        )
    }

    public func authorizedRequest<T: Decodable & Sendable>(
        _ route: APIRoute,
        in environment: APIEnvironment,
        allowRetry: Bool = true
    ) async throws -> T {
        let token = try await authorizationManager.validToken()

        let (data, response) = try await dataLoader.data(
            from: route,
            in: environment,
            token: token
        )
        return try await handleResponse(
            requestResponse: (data: data, response: response),
            for: route,
            in: environment,
            allowRetry: allowRetry
        )
    }
}

private extension StoreClient {

    func handleResponse<T: Decodable & Sendable>(
        requestResponse: (data: Data, response: URLResponse),
        for route: APIRoute,
        in environment: APIEnvironment,
        allowRetry: Bool
    ) async throws -> T {
        guard let httpResponse = requestResponse.response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        switch httpResponse.statusCode {
        case 200...299:
            logResponse(data: requestResponse.data, response: httpResponse)
            return try await decodeResponse(requestResponse.data)
        case 401, 403:
            // Unauthorized or Forbidden (likely token expired), attempt to refresh token and retry request once.
            return try await refreshTokenAndRetryRequestOnce(
                for: route,
                in: environment,
                allowRetry: allowRetry)
        case 400...499:
            throw try await handleClientError(responseData: requestResponse.data)
        case 500...599:
            throw NetworkError.requestFailed(statusCode: httpResponse.statusCode, message: httpResponse.description)
        default:
            throw NetworkError.invalidResponse
        }
    }

    func decodeResponse<T: Decodable>(_ data: Data) async throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }

    func refreshTokenAndRetryRequestOnce<T: Decodable & Sendable>(
        for route: APIRoute,
        in environment: APIEnvironment,
        allowRetry: Bool
    ) async throws -> T {
        guard allowRetry else { throw NetworkError.unauthorized }
        _ = try await authorizationManager.refreshToken()
        return try await authorizedRequest(
            route,
            in: environment,
            allowRetry: false)
    }

    func handleClientError(responseData: Data) async throws -> NetworkError {
        do {
            let error = try decoder.decode(ServerError.self, from: responseData)
            return NetworkError.internalServerError(message: error.error)
        } catch {
            if let errorString = String(data: responseData, encoding: .utf8) {
                return NetworkError.internalServerError(message: errorString)
            }
            return NetworkError.decodingError
        }
    }

    func logResponse(data: Data, response: URLResponse) {
        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            Logger.networking.debug("\(String(decoding: jsonData, as: UTF8.self))")
        }
    }
}
