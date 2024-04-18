//
//  PokemonListViewModelTests.swift
//  PokedexTests
//
//  Created by Kevin Lu on 2024/4/18.
//

import XCTest
@testable import Pokedex

class PokemonListViewModelTests: XCTestCase {
    var mockAPIService: MockAPIService!
    var viewModel: PokemonListViewModel!

    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        viewModel = PokemonListViewModel(apiService: mockAPIService)
    }

    override func tearDown() {
        mockAPIService = nil
        viewModel = nil
        super.tearDown()
    }

    func testLoadPokemons() {
        let expectation = XCTestExpectation(description: "Load pokemons")
        
        viewModel.didLoadPokemons = {
            XCTAssertEqual(self.viewModel.pokedex.count, 2)
            
            XCTAssertEqual(self.viewModel.pokedex[0].id, 1)
            XCTAssertEqual(self.viewModel.pokedex[0].name, "bulbasaur")
            XCTAssertEqual(self.viewModel.pokedex[0].types[0].type.name, "grass")
            XCTAssertEqual(self.viewModel.pokedex[0].types[1].type.name, "poison")
            XCTAssertEqual(self.viewModel.pokedex[0].imageURL.frontDefault, "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png")
            
            XCTAssertEqual(self.viewModel.pokedex[1].id, 2)
            XCTAssertEqual(self.viewModel.pokedex[1].name, "ivysaur")
            XCTAssertEqual(self.viewModel.pokedex[1].types[0].type.name, "grass")
            XCTAssertEqual(self.viewModel.pokedex[1].types[1].type.name, "poison")
            XCTAssertEqual(self.viewModel.pokedex[1].imageURL.frontDefault, "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/2.png")
            
            expectation.fulfill()
        }
        
        viewModel.loadPokemons()
        
        wait(for: [expectation], timeout: 5.0)
    }
}

class MockAPIService: APIServiceProtocol {
    func callAPI<T>(url: String, completion: @escaping (Result<T, NetworkError>) -> Void) where T : Decodable {
        if url.contains("offset") && url.contains("limit") {
            completion(.success(MockData.pagination as! T))
        } else if url.contains("pokemon/1") {
            completion(.success(MockData.bulbasaur as! T))
        } else if url.contains("pokemon/2") {
            completion(.success(MockData.ivysaur as! T))
        }
    }
}

enum MockData {
    static let pagination = Pagination(
        results: [
            NameURLPair(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/"), NameURLPair(name: "ivysaur", url: "https://pokeapi.co/api/v2/pokemon/2/")
        ]
    )
    
    static let bulbasaur = Pokemon(
        id: 1,
        name: "bulbasaur",
        stats: [
                PokemonStat(baseStat: 45, stat: NameURLPair(name: "hp", url: "https://pokeapi.co/api/v2/stat/1/")),
                PokemonStat(baseStat: 49, stat: NameURLPair(name: "attack", url: "https://pokeapi.co/api/v2/stat/2/")),
                PokemonStat(baseStat: 49, stat: NameURLPair(name: "defense", url: "https://pokeapi.co/api/v2/stat/3/")),
                PokemonStat(baseStat: 65, stat: NameURLPair(name: "special-attack", url: "https://pokeapi.co/api/v2/stat/4/")),
                PokemonStat(baseStat: 65, stat: NameURLPair(name: "special-defense", url: "https://pokeapi.co/api/v2/stat/5/")),
                PokemonStat(baseStat: 45, stat: NameURLPair(name: "speed", url: "https://pokeapi.co/api/v2/stat/6/"))
        ],
        types: [
                PokemonType(slot: 1, type: NameURLPair(name: "grass", url: "https://pokeapi.co/api/v2/type/12/")),
                PokemonType(slot: 2, type: NameURLPair(name: "poison", url: "https://pokeapi.co/api/v2/type/4/"))
        ],
        sprites: PokemonSprites(frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png", frontFemale: nil),
        species: NameURLPair(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon-species/1/")
    )
    
    static let ivysaur = Pokemon(
            id: 2,
            name: "ivysaur",
            stats: [
                PokemonStat(baseStat: 60, stat: NameURLPair(name: "hp", url: "https://pokeapi.co/api/v2/stat/1/")),
                PokemonStat(baseStat: 62, stat: NameURLPair(name: "attack", url: "https://pokeapi.co/api/v2/stat/2/")),
                PokemonStat(baseStat: 63, stat: NameURLPair(name: "defense", url: "https://pokeapi.co/api/v2/stat/3/")),
                PokemonStat(baseStat: 80, stat: NameURLPair(name: "special-attack", url: "https://pokeapi.co/api/v2/stat/4/")),
                PokemonStat(baseStat: 80, stat: NameURLPair(name: "special-defense", url: "https://pokeapi.co/api/v2/stat/5/")),
                PokemonStat(baseStat: 60, stat: NameURLPair(name: "speed", url: "https://pokeapi.co/api/v2/stat/6/"))
            ],
            types: [
                PokemonType(slot: 1, type: NameURLPair(name: "grass", url: "https://pokeapi.co/api/v2/type/12/")),
                PokemonType(slot: 2, type: NameURLPair(name: "poison", url: "https://pokeapi.co/api/v2/type/4/"))
            ],
            sprites: PokemonSprites(frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/2.png", frontFemale: nil),
            species: NameURLPair(name: "ivysaur", url: "https://pokeapi.co/api/v2/pokemon-species/2/")
    )
}
