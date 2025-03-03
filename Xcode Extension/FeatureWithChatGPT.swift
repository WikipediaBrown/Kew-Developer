//
//  FeatureWithChatGPT.swift
//  Xcode Extension
//
//  Created by nonplus on 3/2/25.
//

import DeviceCheck
import Foundation
import XcodeKit


class FeatureWithChatGPT: NSObject, XCSourceEditorCommand {
    func perform(with invocation: XCSourceEditorCommandInvocation) async throws {
        let lines = invocation.buffer.lines
        
        guard let selectionLines = invocation.buffer.selections[0] as? XCSourceTextRange else { return }
        guard let prompt = invocation.buffer.lines.object(at: selectionLines.start.line) as? String else { return }
        let selectedTextEnd = selectionLines.end.line
        
        
        let message = Message(role: .user, content: prompt)

        let request = ChatGPTRequest(message: message)
        let url = URL(string: "http://localhost:3000/api/ChatGPT/4o/dev")!

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let jsonData = try JSONEncoder().encode(request)
        urlRequest.httpBody = jsonData
        urlRequest.httpMethod = "POST"

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        let decodedResponse = try JSONDecoder().decode(ChatGPTResponse.self, from: data)
        lines.insert(decodedResponse.message.content, at: selectedTextEnd)
        
        
        let deviceSupported = DCDevice.current.isSupported
        let token = try await DCDevice.current.generateToken()
        
        let serviceSupported = DCAppAttestService.shared.isSupported
        let key = try await DCAppAttestService.shared.generateKey()
        let attestKey = try await DCAppAttestService.shared.attestKey(String(), clientDataHash: Data())
        let assertion = try await DCAppAttestService.shared.generateAssertion(String(), clientDataHash: Data())

        print("deviceSupported: \(deviceSupported)")
        print("serviceSupported: \(serviceSupported)")

    }
}
