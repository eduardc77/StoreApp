//
//  EmailAvailability.swift
//  Networking
//

public struct EmailAvailabilityDTO: Codable {
    let isAvailable: Bool
}

extension EmailAvailabilityDTO: Sendable {}
