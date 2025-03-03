//
//  NetworkingError.swift
//  Xcode Extension
//
//  Created by nonplus on 2/28/25.
//

enum NetworkingError: Error {
    case responseNotHTTPURLResponse
    case networkErrorResponse(response: HTTPResponseCode)
    case maximumRetries
}
