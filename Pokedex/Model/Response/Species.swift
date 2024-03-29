//
//  Species.swift
//  Pokedex
//
//  Created by Kevin Lu on 2024/3/26.
//

import Foundation

import Foundation

struct Species: Codable {
    let flavorTextEntries: [FlavorTextEntry]
    let evolutionChain: EvolutionChain
    
    enum CodingKeys: String, CodingKey {
        case flavorTextEntries = "flavor_text_entries"
        case evolutionChain = "evolution_chain"
    }
}

struct EvolutionChain: Codable {
    let url: String
}

struct FlavorTextEntry: Codable {
    let flavorText: String
    let language: NameURLPair
    let version: NameURLPair
    
    enum CodingKeys: String, CodingKey {
        case flavorText = "flavor_text"
        case language, version
    }
}
