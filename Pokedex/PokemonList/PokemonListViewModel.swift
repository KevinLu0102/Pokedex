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
    private let apiService: APIServiceProtocol
    var pokedex = [Pokedex]()
    var pokemonFavorite: [Pokedex] {
        return FavoriteService.shared.getFavoritePokemon()
    }
    var didLoadPokemons: (() -> Void)?
    
    var displayStyle: DisplayStyle = .List {
        didSet {
            displayStatus?(displayStyle)
        }
    }
    var displayStatus: ((DisplayStyle) -> Void)?
    
    var isLoading: Bool = false {
        didSet {
            loadingStatus?(isLoading)
        }
    }
    var loadingStatus: ((Bool) -> Void)?
    
    var isFavoriteMode: Bool = false {
        didSet {
            favoriteStatus?()
            isFavoriteEmpty = isFavoriteMode && pokemonFavorite.isEmpty
        }
    }
    var favoriteStatus: (() -> Void)?
    
    var isFavoriteEmpty: Bool = false {
        didSet {
            emptyFavoriteStatus?(isFavoriteEmpty)
        }
    }
    var emptyFavoriteStatus: ((Bool) -> Void)?
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
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
    
    func checkFavoriteStatus() {
        if isFavoriteMode {
            favoriteStatus?()
            emptyFavoriteStatus?(pokemonFavorite.isEmpty)
        }
    }
    
    func loadMore(currentRow: Int) {
        if isFavoriteMode{
            return
        }else{
            guard currentRow == pokedex.count - 1 else { return }
            loadPokemons()
        }
    }
    
    func prefetch(indexPaths: [IndexPath]) {
        if isFavoriteMode{
            return
        }else{
            let lastIndexPath = IndexPath(item: pokedex.count - 1, section: 0)
            if indexPaths.contains(lastIndexPath) { loadPokemons() }
        }
    }
    
    func loadPokemons() {
        guard !isLoading else { return }
        
        isLoading = true
        
        let url = "https://pokeapi.co/api/v2/pokemon?offset=\(currentOffset)&limit=\(limit)"
        apiService.callAPI(url: url) { (result: Result<Pagination, NetworkError>) in
            switch result {
            case .success(let success):
                let group = DispatchGroup()
                var tempPokemons = Array<Pokemon?>(repeating: nil, count: success.results.count)
                
                for (index, pokedex) in success.results.enumerated() {
                    group.enter()
                    self.apiService.callAPI(url: pokedex.url) { (result: Result<Pokemon, NetworkError>) in
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
                    
                    self.didLoadPokemons?()
                }
                
            case .failure(let failure):
                self.isLoading = false
                print(failure.localizedDescription)
            }
        }
    }
}
