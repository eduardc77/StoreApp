//
//  APIRoute.swift
//  Store
//

import Foundation

public protocol APIRoute: APIRequestData, Sendable {
    
    /// The HTTP method to use for the route.
    var httpMethod: HTTPMethod { get }
    
    /// The route's ``ApiEnvironment`` relative path.
    var path: String { get }
    
    /// Optional form data, which is sent as request body.
    var formParams: [String: String]? { get }
    
    /// Optional upload data, which is sent as request body.
    var uploadData: Data? { get }
    
    var mockFile: String? { get }
}

extension APIRoute {
    
    var headers: [String: String]? { nil }
    
    var formParams: [String: String]? { nil }
    
    var uploadData: Data? { nil }
}

extension APIRoute {
    
    /// Convert ``encodedFormItems`` to `.utf8` encoded data.
    var encodedFormData: Data? {
        guard let formParams, !formParams.isEmpty else { return nil }
        var params = URLComponents()
        params.queryItems = encodedFormItems
        let paramString = params.query
        return paramString?.data(using: .utf8)
    }
    
    /// Convert ``formParams`` to form encoded query items.
    var encodedFormItems: [URLQueryItem]? {
        formParams?
            .map { URLQueryItem(name: $0.key, value: $0.value.formEncoded()) }
            .sorted { $0.name < $1.name }
    }
    
    /// Get a `URLRequest` for the route and its properties.
    func urlRequest(for env: APIEnvironment, token: OAuthToken? = nil) throws -> URLRequest {
        let urlComponents = makeURLComponents(from: env)
        guard let requestURL = urlComponents.url else {
            throw NetworkError.invalidURLInComponents(urlComponents)
        }
        let urlRequest = makeURLRequest(from: requestURL, env: env, token: token)
        return urlRequest
    }

    private func makeURLComponents(from environment: APIEnvironment) -> URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = environment.scheme
        urlComponents.host = environment.host
        urlComponents.path = pathComponent(for: environment)
        if !queryItems(for: environment).isEmpty {
            urlComponents.queryItems = queryItems(for: environment)
        }
        return urlComponents
    }

    private func makeURLRequest(from requestURL: URL, env: APIEnvironment, token: OAuthToken? = nil) -> URLRequest {
        var urlRequest = URLRequest(url: requestURL)
        let formData = encodedFormData
        urlRequest.allHTTPHeaderFields = headers(for: env)
        urlRequest.httpBody = formData ?? uploadData
        urlRequest.httpMethod = httpMethod.method

        let isFormRequest = formData != nil
        let contentType: ContentType = isFormRequest ? .form : .json
        urlRequest.setValue(
            contentType.rawValue,
            forHTTPHeaderField: HTTPHeaderField.contentType.rawValue
        )
        if contentType == .json {
            urlRequest.addValue(
                ContentType.json.rawValue,
                forHTTPHeaderField: HTTPHeaderField.accept.rawValue
            )
        }
        if let accessToken = token?.accessToken {
            urlRequest.setValue(
                "\(TokenType.bearer.rawValue) \(accessToken)",
                forHTTPHeaderField: HTTPHeaderField.authorization.rawValue)
        }
        return urlRequest
    }
}

extension APIEnvironment {
    
    /// Get a `URLRequest` for a certain ``ApiRoute``.
    func urlRequest(for route: APIRoute) throws -> URLRequest {
        try route.urlRequest(for: self)
    }
}

private extension APIRoute {
    
    func headers(for env: APIEnvironment) -> [String: String] {
        var result = env.headers ?? [:]
        headers?.forEach {
            result[$0.key] = $0.value
        }
        return result
    }
    
    func queryItems(for env: APIEnvironment) -> [URLQueryItem] {
        let routeData = encodedQueryItems ?? []
        let envData = env.encodedQueryItems ?? []
        return routeData + envData
    }
    
    func pathComponent(for env: APIEnvironment) -> String {
        var pathComponent = ""
        
        if !env.domain.isEmpty {
            pathComponent += env.domain
        }
        if let apiVersion = env.apiVersion?.rawValue {
            pathComponent += apiVersion
        }
        
        pathComponent += path
        
        return pathComponent
    }
}

/**
 Enum for Content Types
 */
enum ContentType: String {
    case json = "application/json"
    case form = "application/x-www-form-urlencoded"
}

/**
 Enum for HTTP Header Fields
 */
enum HTTPHeaderField: String {
    case accept = "Accept"
    case authorization = "Authorization"
    case contentType = "Content-Type"
}
