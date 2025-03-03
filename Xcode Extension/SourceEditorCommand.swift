//
//  SourceEditorCommand.swift
//  Xcode Extension
//
//  Created by nonplus on 2/28/25.
//

import Foundation
import XcodeKit
import Combine

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        // Retrieve the contents of the current source editor.
        let lines = invocation.buffer.lines
        let description = invocation.buffer.description
        let completeBuffer = invocation.buffer.completeBuffer
        let contentUTI = invocation.buffer.contentUTI
        let indentationWidth = invocation.buffer.indentationWidth
        let selections = invocation.buffer.selections
        let tabWidth = invocation.buffer.tabWidth
        let usesTabsForIndentation = invocation.buffer.usesTabsForIndentation
        let invocationDescription = invocation.description
        let cancellationHandler = invocation.cancellationHandler
        let commandIdentifier = invocation.commandIdentifier
        print(lines)
        print(description)
        print(completeBuffer)
        print(contentUTI)
        print(indentationWidth)
        print(selections)
        print(tabWidth)
        print(usesTabsForIndentation)
        print(invocationDescription)
        print(cancellationHandler)
        print(commandIdentifier)

        let url = URL(string: "")
        
        
//        // Reverse the order of the lines in a copy.
//        let updatedText = Array(lines.reversed())
//        lines.removeAllObjects()
//        lines.addObjects(from: updatedText)
//        // Signal to Xcode that the command has completed.
//        completionHandler(nil)
//        print("ok")
    }
    
}
