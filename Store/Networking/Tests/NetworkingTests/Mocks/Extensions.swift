@testable import Networking
import Foundation

extension User {
    static func mock(
        id: Int = 1,
        name: String = "John Doe",
        email: String = "john@example.com",
        password: String = "password123",
        avatar: String = "avatar.jpg",
        role: String = "customer",
        creationAt: String = "2024-01-01",
        updatedAt: String = "2024-01-01"
    ) -> User {
        User(
            id: id,
            name: name,
            email: email,
            password: password,
            avatar: avatar,
            role: role,
            creationAt: creationAt,
            updatedAt: updatedAt
        )
    }
}

extension OAuthTokenDTO {
    static func mock(
        accessToken: String = "test-token",
        refreshToken: String = "test-refresh-token",
        expiryDate: Date? = Date().addingTimeInterval(3600)
    ) -> OAuthTokenDTO {
        OAuthTokenDTO(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiryDate: expiryDate
        )
    }
}

extension LoginResponseData {
    static func mock(
        accessToken: String = "valid-token",
        refreshToken: String = "refresh-token"
    ) -> LoginResponseData {
        LoginResponseData(
            refreshToken: refreshToken,
            accessToken: accessToken
        )
    }
}
