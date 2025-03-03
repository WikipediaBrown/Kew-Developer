//
//  ChatGPT4oRequest+ChatGPT4oResponse.swift
//  Xcode Extension
//
//  Created by nonplus on 3/2/25.
//

import Foundation

struct ChatGPTRequest: Codable {
    let message: Message
}

struct ChatGPTResponse: Codable {
    let message: Message
}
