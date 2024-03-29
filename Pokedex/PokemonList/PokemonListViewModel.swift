//
//  PokemonListViewModel.swift
//  Pokedex
//
//  Created by Kevin Lu on 2024/3/25.
//

import Foundation

class PokemonListViewModel {
    private var currentOffset = 0
    private let limit = 20
    private var isLoading = false
    var isFavoriteMode: Bool = false
    var pokedex = [Pokedex]()
    
    var pokemonFavorite: [Pokedex] {
        return FavoriteService.shared.getFavoritePokemon()
    }
    
    func getNumberOfItems() -> Int {
        if isFavoriteMode {
            return pokemonFavorite.count
        } else {
            return pokedex.count
        }
    }

    func getPokedexForCell(at indexPath: IndexPath) -> Pokedex {
        if isFavoriteMode {
            return pokemonFavorite[indexPath.row]
        } else {
            return pokedex[indexPath.row]
        }
    }

    func getPokedexForDetail(at indexPath: IndexPath) -> Pokedex {
        if isFavoriteMode {
            return pokemonFavorite[indexPath.row]
        } else {
            return pokedex[indexPath.row]
        }
    }
    
    func loadPokemons(completion: @escaping () -> Void) {
        guard !isLoading else { return }
        
        isLoading = true
        
        let url = "https://pokeapi.co/api/v2/pokemon?offset=\(currentOffset)&limit=\(limit)"
        APIService.shared.callAPI(url: url) { (result: Result<Pagination, NetworkError>) in
            switch result {
            case .success(let success):
                let group = DispatchGroup()
                var tempPokemons = Array<Pokemon?>(repeating: nil, count: success.results.count)
                
                for (index, pokedex) in success.results.enumerated() {
                    group.enter()
                    APIService.shared.callAPI(url: pokedex.url) { (result: Result<Pokemon, NetworkError>) in
                        switch result {
                        case .success(let data):
                            tempPokemons[index] = data
                            group.leave()
                        case .failure(let error):
                            print(error.localizedDescription)
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    success.results.enumerated().forEach { (index, item) in
                        guard let pokemon = tempPokemons[index] else { return }
                        self.pokedex.append(Pokedex(id: pokemon.id, name: item.name, types: pokemon.types, imageURL: pokemon.sprites, pokemonURL: item.url))
                    }
                    self.currentOffset += self.limit
                    self.isLoading = false
                    completion()
                }
                
            case .failure(let failure):
                self.isLoading = false
                completion()
                print(failure.localizedDescription)
            }
        }
    }
}
