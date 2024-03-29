//
//  PokemonDetailViewModel.swift
//  Pokedex
//
//  Created by Kevin Lu on 2024/3/26.
//

import Foundation

class PokemonDetailViewModel {
    var pokemonDetail: PokemonDetail?
    
    var imageURL: URL? {
        if let urlString = pokemonDetail?.pokemon?.sprites.frontDefault {
            return URL(string: urlString)
        } else {
            return nil
        }
    }
    
    var id: String {
        if let id = pokemonDetail?.pokemon?.id{
            return String(format: "#%04d", id)
        }else{
            return ""
        }
    }
    
    var name: String {
        if let name = pokemonDetail?.pokemon?.name{
            return name
        }else{
            return ""
        }
    }
    
    var types: String {
        if let types = pokemonDetail?.pokemon?.types{
            return types.map { $0.type.name }.joined(separator: ", ")
        }else{
            return ""
        }
    }
    
    var description: String {
        if let species = pokemonDetail?.species {
            return localizedFlavorText(from: species.flavorTextEntries)
        }else{
            return ""
        }
    }
    
    var statsCount: Int {
        if let count = pokemonDetail?.pokemon?.stats.count {
            return count
        }else{
            return 0
        }
    }
    
    var evolutionSpecies: [NameURLPair] {
        if let evolution = pokemonDetail?.evolution{
            var species: [NameURLPair] = []
            collectSpecies(from: evolution.chain, into: &species)
            return species
        }else{
            return []
        }
    }
    
    var isFavorite: Bool {
            if let pokemon = pokemonDetail?.pokemon {
                return FavoriteService.shared.isFavorite(pokemonId: pokemon.id)
            } else {
                return false
            }
        }
    
    func getStat(index: Int) -> PokemonStat?{
        if let stat = pokemonDetail?.pokemon?.stats[index]{
            return stat
        }else{
            return nil
        }
    }
    
    func getStatBackgroundHeight(for stat: PokemonStat, cellHeight: CGFloat) -> CGFloat {
        let maxStatValue = 255.0
        let height = CGFloat(stat.baseStat) / maxStatValue * cellHeight
        return height
    }
    
    func getEvolutionSpecies(index: Int)-> NameURLPair {
        return evolutionSpecies[index]
    }
    
    func updateFavoriteData(pokemonURL: String) {
        if let pokemon = pokemonDetail?.pokemon {
            if FavoriteService.shared.isFavorite(pokemonId: pokemon.id) {
                FavoriteService.shared.removeFavorite(pokemonId: pokemon.id)
            } else {
                FavoriteService.shared.addFavorite(pokemon: Pokedex(id: pokemon.id, name: pokemon.name, types: pokemon.types, imageURL: pokemon.sprites, pokemonURL: pokemonURL))
            }
        }
    }
    
    func loadPokemonDetail(url: String, completion: @escaping () -> Void) {
        pokemonDetail = PokemonDetail()
        self.loadPokemon(url: url) { pokemon in
            guard let pokemon = pokemon else {
                completion()
                return
            }
            self.pokemonDetail?.pokemon = pokemon
            
            self.loadSpecies(url: pokemon.species.url) { species in
                guard let species = species else {
                    completion()
                    return
                }
                self.pokemonDetail?.species = species
                
                self.loadEvolution(url: species.evolutionChain.url) { evolution in
                    guard let evolution = evolution else {
                        completion()
                        return
                    }
                    self.pokemonDetail?.evolution = evolution
                    completion()
                }
            }
        }
    }
    
    private func loadPokemon(url: String, completion: @escaping (Pokemon?) -> Void) {
        APIService.shared.callAPI(url: url) { (result: Result<Pokemon, NetworkError>) in
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
        APIService.shared.callAPI(url: url) { (result: Result<Species, NetworkError>) in
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
        APIService.shared.callAPI(url: url) { (result: Result< Evolution, NetworkError>) in
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
