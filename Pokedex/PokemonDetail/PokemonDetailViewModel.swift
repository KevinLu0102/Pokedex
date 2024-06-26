//
//  PokemonDetailViewModel.swift
//  Pokedex
//
//  Created by Kevin Lu on 2024/3/26.
//

import Foundation

class PokemonDetailViewModel {
    var pokemon: Pokemon? {
        didSet {
            didLoadPokemon?()
        }
    }
    var didLoadPokemon: (() -> Void)?
    
    var species: Species? {
        didSet {
           didLoadSpecies?()
        }
    }
    var didLoadSpecies: (() -> Void)?
    
    var evolution: Evolution? {
        didSet {
           didLoadEvolution?()
        }
    }
    var didLoadEvolution: (() -> Void)?
    
    var isLoading: Bool = false {
        didSet {
            updateLoadingStatus?(isLoading)
        }
    }
    var updateLoadingStatus: ((Bool) -> Void)?
    
    var isFavorite: Bool = false {
        didSet {
            updateIsFavorite?(isFavorite)
        }
    }
    var updateIsFavorite: ((Bool) -> Void)?
    
    var pokemonURL: String?
    
    private let apiService: APIServiceProtocol
    private let favoriteService: FavoriteServiceProtocol
    
    // MARK: - Computed Properties
    var imageURL: URL? {
        if let urlString = pokemon?.sprites.frontDefault {
            return URL(string: urlString)
        } else {
            return nil
        }
    }
    
    var id: String {
        if let id = pokemon?.id{
            return String(format: "#%04d", id)
        }else{
            return ""
        }
    }
    
    var name: String {
        if let name = pokemon?.name{
            return name
        }else{
            return ""
        }
    }
    
    var types: String {
        if let types = pokemon?.types{
            return types.map { $0.type.name }.joined(separator: ", ")
        }else{
            return ""
        }
    }
    
    var description: String {
        if let species = species {
            return localizedFlavorText(from: species.flavorTextEntries)
        }else{
            return ""
        }
    }
    
    var statsCount: Int {
        if let count = pokemon?.stats.count {
            return count
        }else{
            return 0
        }
    }
    
    var evolutionCount: Int {
        return evolutionSpecies.count
    }
    
    var evolutionSpecies: [NameURLPair] {
        if let evolution = evolution{
            var species: [NameURLPair] = []
            collectSpecies(from: evolution.chain, into: &species)
            return species
        }else{
            return []
        }
    }
    // MARK: - Initialization
    init(apiService: APIServiceProtocol, favoriteService: FavoriteServiceProtocol) {
        self.apiService = apiService
        self.favoriteService = favoriteService
    }
    
    // MARK: - Methods
    func getStat(index: Int) ->  PokemonStat? {
        return pokemon?.stats[index]
    }
    
    func getEvolutionSpecies(index: Int) -> NameURLPair{
        return evolutionSpecies[index]
    }
    
    func saveFavoritePokemon() {
        if let pokemon = pokemon, let pokemonURL = pokemonURL {
            if favoriteService.isFavorite(pokemonId: pokemon.id) {
                favoriteService.removeFavorite(pokemonId: pokemon.id)
            } else {
                favoriteService.addFavorite(pokemon: Pokedex(id: pokemon.id, name: pokemon.name, types: pokemon.types, imageURL: pokemon.sprites, pokemonURL: pokemonURL))
            }
            checkIfIsFavorite()
        }
    }
    
    func checkIfIsFavorite() {
        if let pokemon = pokemon{
            isFavorite = favoriteService.isFavorite(pokemonId: pokemon.id)
        }
    }
    
    func loadPokemonDetail() {
        isLoading = true
        
        guard let url = pokemonURL else{ return }
        
        self.loadPokemon(url: url) { pokemon in
            guard let pokemon = pokemon else {
                self.isLoading = false
                return
            }
            self.pokemon = pokemon
            
            self.loadSpecies(url: pokemon.species.url) { species in
                guard let species = species else {
                    self.isLoading = false
                    return
                }
                self.species = species
                
                self.loadEvolution(url: species.evolutionChain.url) { evolution in
                    guard let evolution = evolution else {
                        self.isLoading = false
                        return
                    }
                    self.evolution = evolution
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Private Methods
    private func loadPokemon(url: String, completion: @escaping (Pokemon?) -> Void) {
        apiService.callAPI(url: url) { (result: Result<Pokemon, NetworkError>) in
            switch result {
            case .success(let success):
                completion(success)
            case .failure(let failure):
                completion(nil)
                print(failure.localizedDescription)
            }
        }
    }
    
    private func loadSpecies(url: String, completion: @escaping (Species?) -> Void) {
        apiService.callAPI(url: url) { (result: Result<Species, NetworkError>) in
            switch result {
            case .success(let success):
                completion(success)
            case .failure(let failure):
                completion(nil)
                print(failure.localizedDescription)
            }
        }
    }
    
    private func loadEvolution(url: String, completion: @escaping (Evolution?) -> Void) {
        apiService.callAPI(url: url) { (result: Result< Evolution, NetworkError>) in
            switch result {
            case .success(let success):
                completion(success)
            case .failure(let failure):
                completion(nil)
                print(failure.localizedDescription)
            }
        }
    }
    
    private func collectSpecies(from chain: Chain, into speciesArray: inout [NameURLPair]) {
        speciesArray.append(chain.species)
        
        for nextChain in chain.evolvesTo {
            collectSpecies(from: nextChain, into: &speciesArray)
        }
    }
    
    private func localizedFlavorText(from entries: [FlavorTextEntry]) -> String {
        if let preferredLanguage = Locale.preferredLanguages.first, preferredLanguage.contains("zh-Hant") {
            if let flavorText = getFlavorText(from: entries, language: "zh-Hant", version: "lets-go-pikachu") {
                return flavorText
            }else{
                return "No description data"
            }
        } else {
            if let flavorText = getFlavorText(from: entries, language: "en", version: "lets-go-pikachu") {
                return flavorText
            }else{
                return "No description data"
            }
        }
    }
    
    private func getFlavorText(from entries: [FlavorTextEntry], language: String, version: String) -> String? {
        let filteredEntries = entries.filter { $0.language.name == language && $0.version.name == version }
        return filteredEntries.first?.flavorText.replacingOccurrences(of: "\n", with: " ")
    }
}
