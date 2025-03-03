//
//  HTTPMethod.swift
//  Xcode Extension
//
//  Created by nonplus on 2/28/25.
//

/// Reference: https://tools.ietf.org/html/rfc7231#section-4
enum HTTPMethod: String {
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case connect = "CONNECT"
    case options = "OPTIONS"
    case trace = "TRACE"
    case patch = "PATCH"
}
