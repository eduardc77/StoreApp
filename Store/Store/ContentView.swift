//
//  ContentView.swift
//  Store
//

import SwiftUI

struct ContentView: View {
    @State private var networkMonitor = NetworkMonitor()
    @Environment(AccountManager.self) private var accountManager

    var body: some View {
        if networkMonitor.hasNetworkConnection {
            if accountManager.isLoading {
                ProgressView()
            } else if accountManager.loggedIn {
                HomeScreen()
            } else {
                LoginScreen()
            }
        } else {
            NoNetworkConnectionView()
        }
    }
}

#Preview {
    ContentView()
}
