//
//  Card.swift
//  Flashzilla
//
//  Created by Roman Kavinskyi on 7/11/21.
//

import SwiftUI

struct Card: Codable, Identifiable {
    var id = UUID()
    var prompt: String
    var answer: String
    
    static var example = Card(prompt: "What actor played 13th doctor in series Doctor Who?", answer: "Judy Whitters")
}

extension Card {
    
    var image: UIImage? {
        let dummyImage = UIImage(systemName: "person")
        do {
            let filename = getDocumentsDirectory().appendingPathComponent(id.uuidString)
            let data = try Data(contentsOf: filename)
            return UIImage(data: data)
        } catch {
            print("error loading data")
            return dummyImage
        }
    }
    
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
}

