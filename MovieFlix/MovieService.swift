//
//  MovieService.swift
//  MovieFlix
//
//  Created by Royal K on 2025-02-24.
//

import Foundation

// Protocol defining movie-specific API operations
protocol MovieServiceProtocol {
    func fetchPopularMovies(page: Int) async throws -> MovieResponse
    func fetchMovieDetails(id: Int) async throws -> Movie
    func searchMovies(query: String, page: Int) async throws -> MovieResponse
}

// Implementation of the movie service
class MovieService: MovieServiceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    // Fetches popular movies with pagination
    func fetchPopularMovies(page: Int = 1) async throws -> MovieResponse {
        let params = [
            "page": "\(page)",
            "language": "en-US"
        ]

        return try await networkService.fetch(
            from: Constants.API.popularMovies,
            params: params,
            responseType: MovieResponse.self
        )
    }

    // detailed information for a specific movie
    func fetchMovieDetails(id: Int) async throws -> Movie {
        let params = ["language": "en-US", "append_to_response": "videos,credits"]

        return try await networkService.fetch(
            from: Constants.API.movieDetails + "\(id)",
            params: params,
            responseType: Movie.self
        )
    }

    // Searches for movies matching a query string
    func searchMovies(query: String, page: Int = 1) async throws -> MovieResponse {
        let params = [
            "query": query,
            "page": "\(page)",
            "language": "en-US",
            "include_adult": "false"
        ]

        return try await networkService.fetch(
            from: Constants.API.searchMovie,
            params: params,
            responseType: MovieResponse.self
        )
    }
}
