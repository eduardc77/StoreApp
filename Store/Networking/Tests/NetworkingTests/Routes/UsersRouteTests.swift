@testable import Networking
import Testing
import Foundation

@Suite("Users Route Tests")
struct UsersRouteTests {

    @Test("Create user route configuration")
    func testCreateUserRoute() throws {
        let registerData = RegisterFormData(
            name: "Test User",
            email: "test@example.com",
            password: "password123",
            avatar: "https://example.com/avatar.jpg"
        )
        let route = Store.Users.createUser(registerFormData: registerData)
        let request = try route.urlRequest(for: Store.Environment.develop)

        #expect(request.httpMethod == "POST")
        #expect(request.url?.path == "/api/v1/users")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == ContentType.form.rawValue)
    }

    @Test("Email availability route configuration")
    func testEmailAvailabilityRoute() throws {
        let route = Store.Users.isEmailAvailable("test@example.com")
        let request = try route.urlRequest(for: Store.Environment.develop)

        #expect(request.httpMethod == "POST")
        #expect(request.url?.path == "/api/v1/users/is-available")
    }

    @Test("Update user route configuration")
    func testUpdateUserRoute() throws {
        let route = Store.Users.updateUser(id: 1, name: "Updated Name", email: "updated@example.com")
        let request = try route.urlRequest(for: Store.Environment.develop)

        #expect(request.httpMethod == "PUT")
        #expect(request.url?.path == "/api/v1/users/1")
    }
}
