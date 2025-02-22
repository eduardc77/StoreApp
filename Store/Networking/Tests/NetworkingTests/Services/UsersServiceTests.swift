@testable import Networking
import Testing
import Foundation

@Suite("Users Service Tests")
struct UsersServiceTests {

    func setUp() async {
        await MockURLProtocol.reset()
        URLProtocol.registerClass(MockURLProtocol.self)
    }

    func tearDown() async {
        URLProtocol.unregisterClass(MockURLProtocol.self)
    }

    @Test("Register user succeeds")
    func testRegister() async throws {
        let (client, _) = makeTestClient()
        let service = UsersService(client: client)

        let mockUser = User.mock()
        let state = await MockURLProtocol.state
        await state.setMockResponse(
            try await makeTestResponse(data: mockUser, path: "/users"),
            for: "/api/v1/users"
        )

        let registerData = RegisterFormData(
            name: "Test User",
            email: "test@example.com",
            password: "password123",
            avatar: "https://example.com/avatar.jpg"
        )

        let result: User = try await service.register(with: registerData)

        #expect(result.id == mockUser.id)
        #expect(result.name == mockUser.name)
    }

    @Test("Email availability check succeeds")
    func testEmailAvailability() async throws {
        let (client, _) = makeTestClient()
        let service = UsersService(client: client)

        let mockResponse = EmailAvailabilityDTO(isAvailable: true)
        let state = await MockURLProtocol.state
        await state.setMockResponse(
            try await makeTestResponse(data: mockResponse, path: "/users/is-available"),
            for: "/api/v1/users/is-available"
        )

        let result: EmailAvailabilityDTO = try await service.isEmailAvailable("test@example.com")

        #expect(result.isAvailable == true)
    }
}
