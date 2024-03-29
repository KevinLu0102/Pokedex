//
//  Pagination.swift
//  Pagination
//
//  Created by Kevin Lu on 2024/3/26.
//

import Foundation

struct Pagination: Codable {
    let results: [NameURLPair]
}

struct NameURLPair: Codable {
    let name: String
    let url: String
}
