//
//  AccountView.swift
//  Store
//

import SwiftUI

struct AccountView: View {
    @Environment(AccountManager.self) private var accountManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var editMode: Bool = false
    @State private var name: String = ""
    @State private var email: String = ""
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }()
    
    var body: some View {
        NavigationStack {
            Form {
                if let profile = accountManager.userProfile {
                    VStack {
                        if let avatarURL = URL(string: profile.avatar) {
                            AsyncImage(url: avatarURL) { image in
                                image
                                    .resizable()
                                    .frame(width: 80, height: 80)
                            } placeholder: {
                                Color.gray
                            }
                            .clipShape(Circle())
                            .frame(maxWidth: .infinity)
                        }
                        
                        Group {
                            if editMode {
                                TextField("Account.NameLabel.Title", text: $name)
                                    .textFieldStyle(.roundedBorder)
                            } else {
                                Text(profile.name)
                                    .overlay(alignment: .leading) {
                                        Label("Account.PremiumMemberStatus.Title", systemImage: "checkmark.seal.fill")
                                            .foregroundStyle(.tint)
                                            .labelStyle(.iconOnly)
                                            .alignmentGuide(.leading) { $0[.trailing] + 4 }
                                    }
                            }
                        }
                        .font(.headline.bold())
                        
                        if let joinDate = Self.dateFormatter.date(from: profile.creationAt ?? "") {
                            Text("Joined \(joinDate.formatted(.dateTime.month(.wide).day(.twoDigits).year()))",
                                 comment: "Variable is the calendar date when the person joined.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .listRowInsets(.none)
                    .listRowBackground(Color.clear)
                    
                    Section {
                        if editMode {
                            TextField("Account.EmailLabel.Title", text: $email)
                                .textFieldStyle(.roundedBorder)
                        } else {
                            LabeledContent {
                                Text(profile.email)
                            } label: {
                                Text("Account.EmailLabel.Title")
                            }
                        }
                        LabeledContent {
                            Text(profile.role)
                        } label: {
                            Text("Account.RoleLabel.Title")
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Account.Title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Acount.EditButton.Title") {
                        editMode = true
                    }
                    .disabled(editMode == true)
                }
                ToolbarItem(placement: .confirmationAction) {
                    if editMode {
                        AsyncButton("Acount.SaveButton.Title") {
                            guard let profile = accountManager.userProfile else { return }
                            if name != profile.name || email != profile.email {
                                await accountManager.updateUser(name: name, email: email)
                            }
                            editMode = false
                        }
                        .disabled(name.isEmpty || email.isEmpty)
                    } else {
                        Button("Acount.DoneButton.Title") {
                            dismiss()
                        }
                    }
                }
            }
        }
        .task {
            await accountManager.fetchProfile()
            if let profile = accountManager.userProfile {
                name = profile.name
                email = profile.email
            }
        }
    }
}

#Preview {
    AccountView()
}
