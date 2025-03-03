//
//  DocumentWithChatGPT.swift
//  Xcode Extension
//
//  Created by nonplus on 3/2/25.
//

import Foundation
import XcodeKit
import Combine

class DocumentWithChatGPT: NSObject, XCSourceEditorCommand {
        
//    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping ((any Error)?) -> Void) {
//        let lines = invocation.buffer.lines
//        let model: Model = .gpt4oMini
//        let role: Role = .user
//        let prompt = "Can you add in-line documentation to just the code in this text? Only answer with the update text do not add anything else to yoru response."
//        let message = Message(role: role, content: "\(prompt): \(lines)?")
//        
//        let idempotencyKey: UUID = UUID()
//
//        let request = ChatGPT4oRequest(model: model, messages: [message], store: false)
//        let url = URL("http://localhost:3000/api/ChatGPT/4o")
//        
//    }
    
    func perform(with invocation: XCSourceEditorCommandInvocation) async throws {
        let lines = invocation.buffer.lines
        let model: Model = .gpt4oMini
        let role: Role = .user
        let prompt = "Can you add in-line documentation to just the code in this text?"
        let message = Message(role: role, content: "\(prompt): \(lines)?")
                
        let request = ChatGPTRequest(message: message)
        let url = URL(string: "http://localhost:3000/api/ChatGPT/4o/doc")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let jsonData = try JSONEncoder().encode(request)
        urlRequest.httpBody = jsonData
        urlRequest.httpMethod = "POST"
                
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        let decodedResponse = try JSONDecoder().decode(ChatGPTResponse.self, from: data)

        lines.removeAllObjects()
        lines.add(decodedResponse.message.content)
    }
}

