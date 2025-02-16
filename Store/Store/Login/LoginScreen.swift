//
//  LoginScreen.swift
//  Store
//

import SwiftUI

struct LoginScreen: View {
    @Environment(AccountManager.self) private var accountManager
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    TextField("Login.UsernameField.Title", text: Bindable(accountManager).credentials.email)
                    SecureField("Login.PasswordField.Title", text: Bindable(accountManager).credentials.password)
                }
                .textFieldStyle(.roundedBorder)
                
                NavigationLink {
                    RegisterScreen()
                } label: {
                    Text("Login.RegisterButton.Title")
                }
                
                AsyncButton(
                    action: accountManager.login,
                    label: {
                        Text("Login.LoginButton.Title")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)
                    }
                )
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Login.Title")
            .padding()
        }
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}
