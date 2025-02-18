//
//  Users.swift
//  Store
//

extension Store {

    /// This enum defines the currently supported API routes.
    enum Users: APIRoute {
        case createUser(registerFormData: RegisterFormData)
        case isEmailAvailable(_ email: String)
        case updateUser(id: Int, name: String, email: String)
    }
}

extension Store.Users {

    var path: String {
        switch self {
        case .createUser:
            return "/users"
        case .isEmailAvailable:
            return "/users/is-available"
        case .updateUser(let id, _, _):
            return "/users/\(id)"
        }
    }

    var queryParams: [String: String]? { return nil }

    var formParams: [String: String]? {
        switch self {
        case .createUser(let registerFormData):
            return [
                "name": registerFormData.name,
                "email": registerFormData.email,
                "password": registerFormData.password,
                "avatar": registerFormData.avatar
            ]
        case .isEmailAvailable(let email):
            return ["email": email]
        case .updateUser(_, let name, let email):
            return [
                "name": name,
                "email": email
            ]
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .createUser, .isEmailAvailable:
            return .post
        case .updateUser:
            return .put
        }
    }

    var mockFile: String? {
        switch self {
        case .createUser:
            return "_mockCreateUserResponse"
        case .isEmailAvailable:
            return nil
        case .updateUser:
            return "_mockUpdateUserResponse"
        }
    }
}
