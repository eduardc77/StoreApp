//
//  AsyncButton.swift
//  StoreApp
//

import SwiftUI

struct AsyncButton<Label: View>: View {
    var role: ButtonRole?
    var action: () async -> Void
    @ViewBuilder let label: () -> Label
    
    @MainActor
    @State private var isRunning = false
    
    var body: some View {
        Button(role: role) {
            isRunning = true
            Task { @MainActor in
                await action()
                // TODO: figure out if this is necessary
                //async { @MainActor in
                isRunning = false
                //}
            }
        } label: {
            label()
                .opacity(isRunning ? 0.25 : 1)
                .overlay {
                    if isRunning {
                        ProgressView()
                    }
                }
        }
        .disabled(isRunning)
    }
}

extension AsyncButton where Label == Text {
    init(
        _ titleKey: LocalizedStringKey,
        role: ButtonRole? = nil,
        action: @escaping () async -> Void
    ) {
        self.init(role: role, action: action) { Text(titleKey) }
    }
}
