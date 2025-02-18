//
//  Store+Environment.swift
//  Store
//

extension Store {

    enum Environment: APIEnvironment {
        case production
        case preproduction
        case develop
    }
}

extension Store.Environment {

    var host: String {
        switch self {
        case .production: return ""
        case .preproduction: return ""
        case .develop: return "api.escuelajs.co"
        }
    }

    var headers: [String: String]? {
        switch self {
        case .production: return nil
        case .preproduction: return nil
        case .develop:
            return [
                "X-Use-Cache": "true",
                //"x-mock-match-request-body": "true"
            ]
        }
    }

    var queryParams: [String: String]? { nil }

    var apiVersion: APIVersion? { .version1 }

    var domain: String { "/api" }
}
