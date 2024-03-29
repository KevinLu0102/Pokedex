//
//  APIService.swift
//  Pokedex
//
//  Created by Kevin Lu on 2024/3/25.
//

import Foundation

class APIService {
    static let shared = APIService()
    
    private init() {}
    
    func callAPI<T: Decodable>(url: String, completion: @escaping (Result<T, NetworkError>) -> Void) {
                
        guard let url = URL(string: url) else {
            completion(.failure(.dataError))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.requestError(error)))
            } else {
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.invalidError))
                    return
                }
                guard httpResponse.statusCode == 200 else {
                    completion(.failure(.responseError(httpResponse.statusCode)))
                    return
                }
                guard let data = data else {
                    completion(.failure(.dataError))
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(decodedData))
                    }
                } catch let decodingError as DecodingError {
                    completion(.failure(.decodingError(decodingError)))
                } catch {
                    completion(.failure(.unknownError(error)))
                }
            }
        }.resume()
    }
}
