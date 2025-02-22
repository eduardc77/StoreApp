@testable import Networking
import Foundation

actor MockTokenStore: TokenStoreProtocol {
    private var token: OAuthToken?

    func getAuthorizationData() -> OAuthToken? {
        token
    }

    func setAuthorizationData(_ authorizationData: OAuthToken) {
        token = authorizationData
    }

    func deleteAuthorizationData() {
        token = nil
    }
}
