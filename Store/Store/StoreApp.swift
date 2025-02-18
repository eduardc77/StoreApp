//
//  StoreApp.swift
//  Store
//

import SwiftUI

@main
struct StoreApp: App {
    @State private var accountManager = AccountManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(accountManager)
        }
    }
}
