@testable import Networking
import Testing
import Foundation

@Suite("Environment Tests")
struct EnvironmentTests {

    @Test("Develops environment configuration")
    func testDevelopEnvironment() throws {
        let env = Store.Environment.develop

        #expect(env.scheme == "https")
        #expect(env.host == "api.escuelajs.co")
        #expect(env.apiVersion == .version1)
        #expect(env.domain == "/api")

        let headers = env.headers
        #expect(headers?["X-Use-Cache"] == "true")

        // Test URL construction
        let route = Store.Authentication.profile
        let request = try route.urlRequest(for: env)
        #expect(request.url?.absoluteString.hasPrefix("https://api.escuelajs.co/api/v1") == true)
    }
}
