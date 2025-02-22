import Foundation
import KeychainSwift

public protocol TokenStoreProtocol: Actor {
    func getAuthorizationData() -> OAuthToken?
    func setAuthorizationData(_ authorizationData: OAuthToken)
    func deleteAuthorizationData()
}

public actor TokenStore: TokenStoreProtocol {
    enum KeychainKey: String {
        case authorizationData
    }
    
    private let encoder: JSONEncoder = JSONEncoder()
    private let decoder: JSONDecoder = JSONDecoder()
    
    private let keychain: KeychainSwift = {
        let keychain = KeychainSwift()
#if !DEBUG && !targetEnvironment(simulator)
        keychain.accessGroup = AppInfo.keychainGroup
#endif
        return keychain
    }()

    public init() {}

    public func getAuthorizationData() -> OAuthToken? {
        guard let retrievedData = keychain.getData(KeychainKey.authorizationData.rawValue) else { return nil }
        return decodeAuthorizationCredentials(from: retrievedData)
    }
    
    public func setAuthorizationData(_ tokenData: OAuthToken) {
        guard let encodedData = encodeAuthorizationCredentialsToData(tokenData) else { return }
        keychain.set(
            encodedData,
            forKey: KeychainKey.authorizationData.rawValue,
            withAccess: .accessibleAfterFirstUnlock)
    }
    
    public func deleteAuthorizationData() {
        keychain.delete(KeychainKey.authorizationData.rawValue)
    }
    
    private func encodeAuthorizationCredentialsToData(_ authorizationCredentials: OAuthToken) -> Data? {
        do {
            let encodedData = try encoder.encode(authorizationCredentials)
            return encodedData
        } catch {
            print("Error encoding Authorization Credentials: \(error)")
            return nil
        }
    }
    
    private func decodeAuthorizationCredentials(from data: Data) -> OAuthTokenDTO? {
        do {
            let authorizationCredentials = try decoder.decode(OAuthTokenDTO.self, from: data)
            return authorizationCredentials
        } catch {
            print("Error decoding Authorization Credentials: \(error)")
            return nil
        }
    }
} 