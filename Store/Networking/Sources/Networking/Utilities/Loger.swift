//
//  Loger.swift
//  StoreApp
//

import OSLog

public extension Logger {
    /// Using your bundle identifier is a great way to ensure a unique identifier.
    private static let subsystem = Bundle.main.bundleIdentifier!

    /// All logs related to networking.
    static let networking = Logger(subsystem: subsystem, category: "networking")
}
