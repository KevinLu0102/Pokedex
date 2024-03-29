//
//  NetworkError.swift
//  Pokedex
//
//  Created by Kevin Lu on 2024/3/27.
//

import Foundation

enum NetworkError: Error {
    case invalidError
    case urlError
    case requestError(Error)
    case dataError
    case decodingError(DecodingError)
    case responseError(Int)
    case unknownError(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidError:
            return "Invalid response from the server"
        case .urlError:
            return "Failed to create url"
        case .requestError(let error):
            return "Request error: \(error.localizedDescription)"
        case .dataError:
            return "No data received from the server"
        case .decodingError(let decodingError):
            switch decodingError {
            case .typeMismatch(let type, let context):
                return "Type mismatch for type \(type) in context: \(context.codingPath)"
            case .valueNotFound(let type, let context):
                return "Value not found for type \(type) in context: \(context.codingPath)"
            case .keyNotFound(let key, let context):
                return "Key '\(key)' not found in context: \(context.codingPath)"
            case .dataCorrupted(let context):
                return "Data corrupted in context: \(context.codingPath)"
            @unknown default:
                return "Unknown decoding error: \(decodingError)"
            }
        case .responseError(let statusCode):
            return "Response error with status code: \(statusCode)"
        case .unknownError(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}
