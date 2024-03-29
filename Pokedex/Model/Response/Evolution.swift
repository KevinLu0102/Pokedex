//
//  Evolution.swift
//  Pokedex
//
//  Created by Kevin Lu on 2024/3/26.
//

import Foundation


struct Evolution: Codable {
    let chain: Chain
    let id: Int
}

struct Chain: Codable {
    let evolvesTo: [Chain]
    let species: NameURLPair
    
    enum CodingKeys: String, CodingKey {
        case evolvesTo = "evolves_to"
        case species
    }
}
