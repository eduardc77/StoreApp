//
//  NetworkMonitor.swift
//  Store
//

import Network
import Observation

@Observable
final class NetworkMonitor {
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "NetworMonitor.queue")
    private var pathStatus: NWPath.Status = .satisfied

    var hasNetworkConnection: Bool {
        pathStatus == .satisfied
    }
    var isUsingMobileConnection = false

    init() {
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    private func startMonitoring() {
        networkMonitor.pathUpdateHandler = { path in
            Task { @MainActor [weak self] in
                self?.pathStatus = path.status
                self?.isUsingMobileConnection = path.usesInterfaceType(.cellular)
            }
        }
        networkMonitor.start(queue: workerQueue)
    }
    
    private func stopMonitoring() {
        networkMonitor.cancel()
    }
}
