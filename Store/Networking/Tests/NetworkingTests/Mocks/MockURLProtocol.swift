@testable import Networking
import Foundation

actor TestStateManager {
    static let shared = TestStateManager()
    private var protocolState = MockURLProtocolState()

    func getState() -> MockURLProtocolState {
        protocolState
    }

    func reset() {
        print("Resetting MockURLProtocol state")
        protocolState = MockURLProtocolState()
    }
}

actor MockURLProtocolState {
    var mockResponses: [String: (Data, URLResponse)] = [:]
    var lastRequest: URLRequest?
    private let id = UUID()

    init() {
        print("Created new MockURLProtocolState: \(id)")
    }

    func setMockResponse(_ response: (Data, URLResponse), for path: String) {
        mockResponses[path] = response
        print("[\(id)] Set mock response for path: \(path)")
    }

    func getMockResponse(for path: String) -> (Data, URLResponse)? {
        print("[\(id)] Get mock response for path: \(path)")
        return mockResponses[path]
    }

    func setLastRequest(_ request: URLRequest) {
        lastRequest = request
        print("[\(id)] Set last request: \(request.url?.path ?? "nil")")
    }

    func getLastRequest() -> URLRequest? {
        print("[\(id)] Get last request: \(lastRequest?.url?.path ?? "nil")")
        return lastRequest
    }
}

@objc class MockURLProtocol: URLProtocol, @unchecked Sendable {
    static var state: MockURLProtocolState {
        get async {
            await TestStateManager.shared.getState()
        }
    }

    static func reset() async {
        await TestStateManager.shared.reset()
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let client = self.client
        let request = self.request

        Task { @Sendable in
            let state = await Self.state
            await state.setLastRequest(request)

            guard let url = request.url,
                  let path = URLComponents(url: url, resolvingAgainstBaseURL: false)?.path,
                  let mockResponse = await state.getMockResponse(for: path) else {
                await MainActor.run {
                    client?.urlProtocol(self, didFailWithError: NetworkError.invalidResponse)
                }
                return
            }

            let (data, response) = mockResponse
            await MainActor.run {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            }
        }
    }

    override func stopLoading() {}
}
