//
//  Authentication.swift
//  Store
//

extension Store {

    /// This enum defines the currently supported API routes.
    enum Authentication: APIRoute {
        case login(credentials: Credentials)
        case profile
        case refreshToken(refreshToken: String)
    }
}

extension Store.Authentication {

    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .profile:
            return "/auth/profile"
        case .refreshToken:
            return "/auth/refresh-token"
        }
    }
    
    var queryParams: [String: String]? { return nil }

    var formParams: [String: String]? {
        switch self {
        case .login(let credentials):
            return [
                "email": credentials.email,
                "password": credentials.password
            ]
        case .profile:
            return nil
        case .refreshToken(let refreshToken):
            return [
                "refreshToken": refreshToken
            ]
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .login, .refreshToken:
            return .post
        case .profile:
            return .get
        }
    }

    var mockFile: String? {
        switch self {
        case .login:
            return "_mockLoginResponse"
        case .profile:
            return "_mockProfileResponse"
        case .refreshToken:
            return "mockRefreshTokenResponse"
        }
    }
}
