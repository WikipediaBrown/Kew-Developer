//
//  Message.swift
//  Xcode Extension
//
//  Created by nonplus on 2/28/25.
//

struct Message: Codable {
    let role: Role
    let content: String
    let refusal: String? = nil
}
