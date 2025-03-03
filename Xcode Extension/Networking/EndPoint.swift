//
//  EndPoint.swift
//  Xcode Extension
//
//  Created by nonplus on 2/28/25.
//

import Foundation

enum EndPoint: String {
    case chatGPT4o = "api/ChatGPT/4o"
    case ollama = "api/chat"

    var method: HTTPMethod {
            switch self {
            case .chatGPT4o: return .post
            case .ollama: return .post
            }
        }
}

extension EndPoint {
    var url: URL {
//        URL(string: "http://localhost:11434/api/chat")!
        ConfigurationService.apiBaseURL.appendingPathComponent(rawValue)
    }
}
