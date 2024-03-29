//
//  Pokemon.swift
//  Pokedex
//
//  Created by Kevin Lu on 2024/3/25.
//

import Foundation

struct Pokemon: Codable {
    let id: Int
    let name: String
    let stats: [PokemonStat]
    let types: [PokemonType]
    let sprites: PokemonSprites
    let species: NameURLPair
}

struct PokemonStat: Codable {
    let baseStat: Int
    let stat: NameURLPair
    
    enum CodingKeys: String, CodingKey {
        case baseStat = "base_stat"
        case stat
    }
}

struct PokemonType: Codable {
    let slot: Int
    let type: NameURLPair
}

struct PokemonSprites: Codable {
    let frontDefault: String
    let frontFemale: String?
    
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case frontFemale = "front_female"
    }
}
