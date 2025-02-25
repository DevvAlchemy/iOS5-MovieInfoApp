//
//  NetworkService.swift
//  MovieFlix
//
//  Created by Royal K on 2025-02-25.
//

import Foundation

// Error types that can occur during network requests
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case requestFailed(Error)

    var errorMessage: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from the server"
        case .invalidData:
            return "Invalid data received"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        }
    }
}

protocol NetworkServiceProtocol {
    func fetch<T: Decodable>(from endpoint: String,
                             params: [String: String]?,
                             responseType: T.Type) async throws -> T
}

// Implementation of the network service
class NetworkService: NetworkServiceProtocol {

    // Fetches data from an API endpoint and decodes it to the specified type
    func fetch<T: Decodable>(from endpoint: String,
                             params: [String: String]? = nil,
                             responseType: T.Type) async throws -> T {

        // Construct the URL with base URL, endpoint, API key and parameters
        var components = URLComponents(string: Constants.API.baseURL + endpoint)

        // Add API key to query parameters
        var queryItems = [URLQueryItem(name: "api_key", value: Constants.API.apiKey)]

        // Add additional parameters if provided
        if let params = params {
            for (key, value) in params {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
        }

        components?.queryItems = queryItems

        // Ensure we have a valid URL
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        // network request
        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            // Validate response is an HTTP response with status code 200-299
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.invalidResponse
            }

            // Decode the response data to the specified type
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(responseType, from: data)
            } catch {
                print("Decoding error: \(error)")
                throw NetworkError.invalidData
            }
        } catch {
            if error is NetworkError {
                throw error
            } else {
                throw NetworkError.requestFailed(error)
            }
        }
    }
}
