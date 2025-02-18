//
//  NoNetworkConnectionView.swift
//  StoreApp
//

import SwiftUI

struct NoNetworkConnectionView: View {

    var body: some View {
        ContentUnavailableView {
            Label("ContentView.NoNetworkConnection.Title", systemImage: "wifi.slash")
        } description: {
            Text("ContentView.NoNetworkConnection.Description")
        }
    }
}

#Preview {
    NoNetworkConnectionView()
}
