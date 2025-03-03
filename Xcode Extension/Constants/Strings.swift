//
//  Strings.swift
//  Xcode Extension
//
//  Created by nonplus on 2/28/25.
//

enum Strings {
    case dismiss
    
    var localized: String {
        switch self {
            case .dismiss: String(localized:"Dismiss", comment: "Title for error alert dismiss button.")
        }
    }
}
