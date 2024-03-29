//
//  PokedexSec.swift
//  Pokedex
//
//  Created by Kevin Lu on 2024/3/27.
//

import Foundation

struct Pokedex: Codable {
    let id: Int
    let name: String
    let types: [PokemonType]
    let imageURL: PokemonSprites
    var pokemonURL: String
}
