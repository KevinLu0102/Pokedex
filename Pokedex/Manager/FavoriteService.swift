//
//  FavoriteService.swift
//  Pokedex
//
//  Created by Kevin Lu on 2024/3/28.
//

import Foundation

protocol FavoriteServiceProtocol {
    func isFavorite(pokemonId: Int) -> Bool
    func addFavorite(pokemon: Pokedex)
    func removeFavorite(pokemonId: Int)
    func getFavoritePokemon() -> [Pokedex]
}

class FavoriteService: FavoriteServiceProtocol {
    static let shared = FavoriteService()
    
    private let favoritePokemonKey = "FavoritePokemon"
    private var favoritePokemon: [Pokedex] = []
    
    private init() {
        loadFavoritePokemon()
    }
    
    func isFavorite(pokemonId: Int) -> Bool {
        return favoritePokemon.contains(where: { $0.id == pokemonId })
    }
    
    func addFavorite(pokemon: Pokedex) {
        if !isFavorite(pokemonId: pokemon.id) {
            favoritePokemon.append(pokemon)
            saveFavoritePokemon()
        }
    }
    
    func removeFavorite(pokemonId: Int) {
        favoritePokemon.removeAll(where: { $0.id == pokemonId })
        saveFavoritePokemon()
    }
    
    func getFavoritePokemon() -> [Pokedex] {
        return favoritePokemon
    }
    
    private func loadFavoritePokemon() {
        if let data = UserDefaults.standard.data(forKey: favoritePokemonKey),
           let decodedPokemon = try? JSONDecoder().decode([Pokedex].self, from: data) {
            favoritePokemon = decodedPokemon
        }
    }
    
    private func saveFavoritePokemon() {
        if let encodedData = try? JSONEncoder().encode(favoritePokemon) {
            UserDefaults.standard.set(encodedData, forKey: favoritePokemonKey)
        }
    }
}
