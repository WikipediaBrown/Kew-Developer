//
//  ConfigurationService.swift
//  Xcode Extension
//
//  Created by nonplus on 2/28/25.
//

import Foundation
import OSLog

struct ConfigurationService {
    
    private static let logger = Logger(forComponent: "Configuration Service", andCategory: #fileID)

    
    enum ConfigurationError: Error {
        case missingKey, invalidValue
    }
    
    static let emulatorAuthPort = 9099
    
    static var maxRetries: Int { value(for: LocalConstants.maxRetries) }
    
    static var apiBaseURL: URL {
        let host: String = value(for: LocalConstants.apiHost)
        let path: String = value(for: LocalConstants.apiPath)
        
        var components = URLComponents()
        components.host = host
        components.path = path
        #if DEBUG
        components.scheme = LocalConstants.http
        components.port = value(for: LocalConstants.port)
        #else
        components.scheme = LocalConstants.https
        #endif
        
        guard let url = components.url
        else {
            fatalError("URL created from Configuration file is invalid for host: \(host) and path: \(path).", file: #file, line: #line)
        }
        return url
    }
    
    static var apiBaseURLHost: String {
        guard let host = apiBaseURL.host()
        else {
            logger.error("API Base URL Host is invalid")
            fatalError("API Base URL Host is invalid")
        }
        return host
    }
    
    private static func value<T>(for key: String) -> T where T: LosslessStringConvertible {
        switch Bundle.main.object(forInfoDictionaryKey:key) {
        case let value as T: return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        case .none:
            logger.error("Information Property List is missing the key: \(key, privacy: .private(mask: .hash))")
            fatalError("Missing Plist key: \(key).", file: #fileID, line: #line)
        default:
            logger.error("Value type: \(T.Type.self)\nis incorrect for : \(key, privacy: .sensitive(mask: .hash))")
            fatalError("Value type: \(T.Type.self)\nis incorrect for : \(key).", file: #file, line: #line)
        }
    }
    
    private enum LocalConstants {
        static let apiHost = "API_HOST"
        static let apiPath = "API_PATH"
        static let http = "http"
        static let https = "https"
        static let maxRetries = "MAX_RETRIES"
        static let port = "PORT"
    }
}
