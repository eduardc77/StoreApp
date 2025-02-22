@testable import Networking
import Testing
import Foundation

@Suite("Network Error Tests")
struct NetworkErrorTests {

    @Test("Maps HTTP status codes to correct errors")
    func testErrorMapping() {
        let message = "Test error"

        #expect(NetworkError.from(httpStatusCode: 400, message: message) == .badRequest(message: message))
        #expect(NetworkError.from(httpStatusCode: 401, message: message) == .unauthorized)
        #expect(NetworkError.from(httpStatusCode: 403, message: message) == .forbidden)
        #expect(NetworkError.from(httpStatusCode: 404, message: message) == .notFound(message: message))
        #expect(NetworkError.from(httpStatusCode: 409, message: message) == .conflict(message: message))
        #expect(NetworkError.from(httpStatusCode: 422, message: message) == .unprocessableEntity(message: message))
        #expect(NetworkError.from(httpStatusCode: 500, message: message) == .internalServerError(message: message))
        #expect(NetworkError.from(httpStatusCode: 503, message: message) == .serviceUnavailable(message: message))
    }
}
