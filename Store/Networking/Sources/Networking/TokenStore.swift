//
//  TokenStore.swift
//  Store
//

import Foundation
import KeychainSwift

protocol TokenStoreProtocol {
    func getAuthorizationData() -> OAuthToken?
    func setAuthorizationData(_ authorizationData: OAuthToken)
    func deleteAuthorizationData()
}

struct TokenStore: TokenStoreProtocol {

    enum KeychainKey: String {
        case authorizationData
    }

    private var encoder: JSONEncoder = { JSONEncoder() }()
    private var decoder: JSONDecoder = { JSONDecoder() }()

    private static var keychain: KeychainSwift {
        let keychain = KeychainSwift()
#if !DEBUG && !targetEnvironment(simulator)
        keychain.accessGroup = AppInfo.keychainGroup
#endif
        return keychain
    }

    func getAuthorizationData() -> OAuthToken? {
        guard let retrievedData = Self.keychain.getData(KeychainKey.authorizationData.rawValue) else { return nil }
        return decodeAuthorizationCredentials(from: retrievedData)
    }

    func setAuthorizationData(_ tokenData: OAuthToken) {
        guard let encodedData = encodeAuthorizationCredentialsToData(tokenData) else { return }
        Self.keychain.set(
            encodedData,
            forKey: KeychainKey.authorizationData.rawValue,
            withAccess: .accessibleAfterFirstUnlock)
    }

    func deleteAuthorizationData() {
        Self.keychain.delete(KeychainKey.authorizationData.rawValue)
    }

    func encodeAuthorizationCredentialsToData(_ authorizationCredentials: OAuthToken) -> Data? {
        do {
            let encodedData = try encoder.encode(authorizationCredentials)
            return encodedData
        } catch {
            print("Error encoding Authorization Credentials: \(error)")
            return nil
        }
    }

    func decodeAuthorizationCredentials(from data: Data) -> OAuthToken? {
        do {
            let authorizationCredentials = try decoder.decode(OAuthToken.self, from: data)
            return authorizationCredentials
        } catch {
            print("Error decoding Authorization Credentials: \(error)")
            return nil
        }
    }
}
