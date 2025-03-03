//
//  LlamaRequest+Response.swift
//  Xcode Extension
//
//  Created by nonplus on 2/28/25.
//

import Foundation

struct LlamaRequest: Codable {
    let model: Model
    let messages: [Message]
    let stream: Bool
}

struct LlamaResponse: Codable {
    let model: String
    let createdAt: String
    let message: Message
    let doneReason: String
    let done: Bool
    let totalDuration: TimeInterval
    let loadDuration: TimeInterval
    let promptEvalCount: Int
    let promptEvalDuration: TimeInterval
    let evalCount: Int
    let evalDuration: TimeInterval
}
