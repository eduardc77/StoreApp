//
//  NeworkError.swift
//  Store
//

import Foundation

enum NetworkError: Error, Equatable, LocalizedError {
    case invalidURLInComponents(URLComponents)
    case requestFailed(statusCode: Int? = nil, message: String)
    case invalidResponse
    case emailUnavailable
    case decodingError
    case authenticationError(message: String)
    case timeoutError
    case unauthorized
    case missingToken
    case expiredToken
    case invalidToken
    case cacheError(message: String)
    case forbidden
    case notFound(message: String)
    case internalServerError(message: String)
    case badRequest(message: String)
    case unprocessableEntity(message: String)
    case conflict(message: String)
    case serviceUnavailable(message: String)
    case invalidRequestBody
    case noInternetConnection
    case customError(message: String)
    
    static func from(httpStatusCode: Int, message: String) -> NetworkError {
        switch httpStatusCode {
        case 200...299: return .requestFailed(statusCode: httpStatusCode, message: message)
        case 400: return .badRequest(message: message)
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .notFound(message: message)
        case 409: return .conflict(message: message)
        case 422: return .unprocessableEntity(message: message)
        case 500: return .internalServerError(message: message)
        case 503: return .serviceUnavailable(message: message)
        default: return .customError(message: message)
        }
    }
}
