//
//  CommentWithLlama.swift
//  Xcode Extension
//
//  Created by nonplus on 2/28/25.
//

import Foundation
import XcodeKit
import Combine

class CommentWithLlama: NSObject, XCSourceEditorCommand {
    
//    let llamaResponsePublisher: AnyPublisher<LlamaResponse, Error>
    
    private let networkingManager: NetworkingManager = {
        let cateFormatter = DateFormatter()
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return NetworkingManager(decoder: decoder)
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {

        let lines = invocation.buffer.lines
//        let description = invocation.buffer.description
//        let completeBuffer = invocation.buffer.completeBuffer
//        let contentUTI = invocation.buffer.contentUTI
//        let indentationWidth = invocation.buffer.indentationWidth
//        let selections = invocation.buffer.selections
//        let tabWidth = invocation.buffer.tabWidth
//        let usesTabsForIndentation = invocation.buffer.usesTabsForIndentation
//        let invocationDescription = invocation.description
//        let cancellationHandler = invocation.cancellationHandler
//        let commandIdentifier = invocation.commandIdentifier

        let model: Model = .llama3
        let role: Role = .user
        let prompt = "Can you add in-line documentation to just the code in this text? Only answer with the update text do not add anything else to yoru response."
        let message = Message(role: role, content: "\(prompt): \(lines)?")
        let messages: [Message] = [message]
        let request = LlamaRequest(model: model, messages: messages, stream: false)
        let idempotencyKey: UUID = UUID()
        
        llamaRequest(request: request)
            .sink { error in
                print(error)
            } receiveValue: { response in
                lines.removeAllObjects()
                lines.add(response.message.content)
                completionHandler(nil)
            }
            .store(in: &cancellables)
    }
    
    func llamaRequest(request: LlamaRequest) -> AnyPublisher<LlamaResponse, Error> {
        let idempotencyKey: UUID = UUID()
        return networkingManager.request(for: .ollama, body: request, idempotencyKey: idempotencyKey)
    }
}
