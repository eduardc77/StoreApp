//
//  HomeScreen.swift
//  Store
//

import SwiftUI

struct HomeScreen: View {
    @Environment(AccountManager.self) private var accountManager

    @State private var showAccountView: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                Text("Home.Welcome.Message")
                    .font(.title)

                Spacer()

                Button(
                    role: .destructive,
                    action: {
                        Task { await accountManager.logout() }
                    },
                    label: {
                        Text("Home.LogoutButton.Title")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)
                    }
                )
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Home.Title")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    profileToolbarItem
                }
            }
            .sheet(isPresented: $showAccountView, content: { AccountView() })
        }
    }

    private var profileToolbarItem: some View {
        Button {
            showAccountView = true
        } label: {
            Label("Home.AccountButton.Title", systemImage: "person.crop.circle")
        }
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
