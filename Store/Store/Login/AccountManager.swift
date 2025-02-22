//
//  AccountManager.swift
//  Store
//

import SwiftUI
import Networking
import KeychainSwift
import OSLog

@Observable
final class AccountManager {
    var accountService: AccountServiceProtocol
    var usersService: UsersServiceProtocol

    var loggedIn: Bool = false
    var isLoading: Bool = false

    var userProfile: User?

    var credentials = Credentials(
        email: "john@mail.com",
        password: "changeme"
    )
    var registerFormData = RegisterFormData(
        name: "John",
        email: "john@mail.com",
        password: "changeme",
        avatar: "https://i.imgur.com/LDOO4Qs.jpg"
    )

    init(
        accountService: AccountServiceProtocol = AccountService(),
        usersService: UsersServiceProtocol = UsersService()
    ) {
        self.accountService = accountService
        self.usersService = usersService
        Task { loggedIn = try await accountService.isAccessTokenValid() }
    }

    func register() async {
        do {
            //            let emailAvailability: EmailAvailabilityDTO = try await usersService.isEmailAvailable(registerFormData.email)
            //            guard emailAvailability.isAvailable else { throw NetworkError.emailUnavailable }
            defer { isLoading = false }
            isLoading = true
            let userResponse: User = try await usersService.register(with: registerFormData)
            credentials = Credentials(email: userResponse.email, password: userResponse.password)
            await login()
        } catch {
            Logger.account.error("Error on register user: \(error.localizedDescription).")
        }
    }

    func login() async {
        do {
            defer { isLoading = false }
            isLoading = true
            let _: LoginResponseData = try await accountService.login(with: credentials)
            loggedIn = true
        } catch {
            Logger.account.error("Error on login: \(error.localizedDescription).")
        }
    }

    func fetchProfile() async {
        do {
            let profileResponse: User = try await accountService.profile()
            userProfile = profileResponse
        } catch {
            Logger.account.error("Error fetching profile: \(error.localizedDescription).")
        }
    }

    func updateUser(name: String, email: String) async {
        guard let userID = userProfile?.id else { return }
        do {
            let userResponse: User = try await usersService.updateUser(with: userID, name: name, email: email)
            userProfile = userResponse
        } catch {
            Logger.account.error("Error updating profile: \(error.localizedDescription).")
        }
    }

    func logout() async {
        defer {
            loggedIn = false
            isLoading = false
        }
        isLoading = true
        await accountService.invalidateToken()
    }
}
