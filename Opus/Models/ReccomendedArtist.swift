//
//  ReccomendedArtist.swift
//  Opus
//
//  Created by Fulin Halvorsen on 05/12/2018.
//  Copyright © 2018 Fulin Halvorsen. All rights reserved.
//

import Foundation


struct ReccomendedRoot: Codable {
    let similar: Similar

    enum CodingKeys: String, CodingKey {
        case similar = "Similar"
    }
}


struct Similar: Codable {
    let results: [Reccomended]

    enum CodingKeys: String, CodingKey {
        case results = "Results"
    }
}


struct Reccomended: Codable {
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
    }
}
enum TypeEnum: String, Codable {
    case music = "music"
}
