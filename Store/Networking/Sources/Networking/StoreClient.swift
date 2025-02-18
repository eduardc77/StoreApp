//
//  StoreClient.swift
//  Networking
//

import Foundation

class StoreClient: APIClient {

    var decoder: JSONDecoder = {
        let aDecoder = JSONDecoder()
        aDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return aDecoder
    }()

    private let dataloader: any HTTPDataLoader
    private let authorizationManager: AuthorizationManager

    init(
        authorizationManager: AuthorizationManager,
        dataloader: any HTTPDataLoader = URLSession.shared
    ) {
        self.authorizationManager = authorizationManager
        self.dataloader = dataloader
    }

    func request<T: Decodable>(
        _ route: APIRoute,
        in environment: APIEnvironment
    ) async throws -> T {
        let (data, response) = try await dataloader.data(from: route, in: environment)
        return try await handleResponse(
            requestResponse: (data: data, response: response),
            for: route,
            in: environment,
            allowRetry: false
        )
    }

    func authorizedRequest<T: Decodable>(
        _ route: APIRoute,
        in environment: APIEnvironment,
        allowRetry: Bool = true
    ) async throws -> T {
        let token = try await authorizationManager.validToken()

        let (data, response) = try await dataloader.data(
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

    func handleResponse<T: Decodable>(
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
            do {
                return try decoder.decode(T.self, from: requestResponse.data)
            } catch {
                throw NetworkError.decodingError
            }
        case 401, 403:
            // Unauthorized or Forbidden (likely token expired), attempt to refresh token and retry request once.
            return try await refreshTokenAndRetryRequestOnce(
                for: route,
                in: environment,
                allowRetry: allowRetry)
        case 400...499:
            if let error = try? decoder.decode(ServerError.self, from: requestResponse.data) {
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
        for route: APIRoute,
        in environment: APIEnvironment,
        allowRetry: Bool
    ) async throws -> T {
        if allowRetry {
            _ = try await authorizationManager.refreshToken()
            return try await authorizedRequest(
                route,
                in: environment,
                allowRetry: false)
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
