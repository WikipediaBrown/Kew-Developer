//
//  Logger+Extension.swift
//  Xcode Extension
//
//  Created by nonplus on 2/28/25.
//

import OSLog

extension Logger {
    
    init(forComponent component: String, andCategory category: String) {
        let subsystem = "\(Logger.bundleIdentifier).\(component)"
        self.init(subsystem: subsystem, category: category)
    }
    
    private static var bundleIdentifier: String {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            let category: String = "Bundle Identifier"
            let subsystem: String = "Logger"
            let message = "Logger Cannot Retrieve Bundle Identifier from Main Bundle"
            Logger(subsystem: subsystem, category: category).critical("\(message)")
            fatalError(message)
        }
        return bundleIdentifier
    }
}
