//
//  RegisterScreen.swift
//  Store
//

import SwiftUI

struct RegisterScreen: View {
    @Environment(AccountManager.self) private var accountManager
    
    var body: some View {
        VStack {
            VStack {
                TextField("Register.NameField.Title", text: Bindable(accountManager).registerFormData.name)
                TextField("Register.UsernameField.Title", text: Bindable(accountManager).registerFormData.email)
                SecureField("Register.PasswordField.Title", text: Bindable(accountManager).registerFormData.password)
            }
            .textFieldStyle(.roundedBorder)
            
            AsyncButton(
                action: accountManager.register,
                label: {
                    Text("Register.RegisterButton.Title")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                }
            )
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    LoginScreen()
}
