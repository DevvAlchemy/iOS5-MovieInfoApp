//
//  APIConstants.swift
//  MovieFlix
//
//  Created by Royal K on 2025-02-24.
//

import Foundation

struct Constants {
    // TMDB API
    struct API {
        static let baseURL = "https://api.themoviedb.org/3"
        static let apiKey = "YOUR_API_KEY"

        // Endpoints
        static let popularMovies = "/movie/popular"
        static let movieDetails = "/movie/"
        static let searchMovie = "/search/movie"
    }

    // UI
    struct UI {
        static let cornerRadius: CGFloat = 10
        static let standardPadding: CGFloat = 16
        static let cardSpacing: CGFloat = 12
    }
}
