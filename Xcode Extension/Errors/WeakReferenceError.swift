//
//  WeakReferenceError.swift
//  Xcode Extension
//
//  Created by nonplus on 2/28/25.
//

import Foundation

enum WeakReferenceError: Error, LocalizedError, RecoverableError {
    
    case selfDeallocated
    
    var errorDescription: String? {
        switch self {
        case .selfDeallocated:
            String(localized: "Object deallocated unexpectedly",
                   comment: "Object deallocated unexpectedly")
        }
    }
    
    
    var recoveryOptions: [String] {
        recoveryActions.map { $0.title }
    }
    
    func attemptRecovery(optionIndex recoveryOptionIndex: Int) -> Bool {
        handleAction(recoveryActions: recoveryActions, recoveryOptionIndex: recoveryOptionIndex)
    }
    
    func attemptRecovery(optionIndex recoveryOptionIndex: Int, resultHandler handler: @escaping (Bool) -> Void) {
        let result = handleAction(recoveryActions: recoveryActions, recoveryOptionIndex: recoveryOptionIndex)
        handler(result)
    }
    
    private func handleAction(recoveryActions: NamedActions, recoveryOptionIndex: Int) -> Bool {
        let title = recoveryActions[recoveryOptionIndex].title
        let action = recoveryActions[recoveryOptionIndex].action
        return action(title)
    }
    
    private var recoveryActions: NamedActions {
        let defaultDismissWithNoOpAction: NamedActions = [(title: Strings.dismiss.localized, action: {_ in true})]
        switch self {
        case .selfDeallocated: return defaultDismissWithNoOpAction
        }
    }
}
