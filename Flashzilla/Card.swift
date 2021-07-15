//
//  Card.swift
//  Flashzilla
//
//  Created by Roman Kavinskyi on 7/11/21.
//

import Foundation

struct Card: Codable, Identifiable {
    var id = UUID()
    var prompt: String
    var answer: String
    
    static var example = Card(prompt: "What actor played 13th doctor in series Doctor Who?", answer: "Judy Whitters")
}
