//
//  RefreshTokenService.swift
//  Networking
//

import Foundation

protocol RefreshTokenNetworkServicing: Sendable {
    func refreshToken(_ refreshToken: String) async throws -> OAuthToken
}

struct RefreshTokenNetworkService: RefreshTokenNetworkServicing {

    private let dataloader: any HTTPDataLoader

    var decoder: JSONDecoder {
        let aDecoder = JSONDecoder()
        aDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return aDecoder
    }

    init(dataloader: any HTTPDataLoader = URLSession.shared) {
        self.dataloader = dataloader
    }

    func refreshToken(_ refreshToken: String) async throws -> OAuthToken {
        let route = Store.Authentication.refreshToken(refreshToken: refreshToken)
        let environment = Store.Environment.develop
        let (data, response) = try await dataloader.data(from: route, in: environment)
        return try await handleResponse(requestResponse: (data: data, response: response))
    }
}

private extension RefreshTokenNetworkService {

    func handleResponse(
        requestResponse: (data: Data, response: URLResponse)
    ) async throws -> OAuthToken {
        guard let httpResponse = requestResponse.response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try decoder.decode(OAuthTokenDTO.self, from: requestResponse.data)
            } catch {
                throw NetworkError.decodingError
            }
        case 401, 403:
            throw NetworkError.unauthorized
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
}
