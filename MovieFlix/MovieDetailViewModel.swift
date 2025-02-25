//
//  MovieDetailViewModel.swift
//  MovieFlix
//
//  Created by Royal K on 2025-02-25.
//

import Foundation
import SwiftUI

@MainActor
class MovieDetailViewModel: ObservableObject {

    @Published var movie: Movie?
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let movieService: MovieServiceProtocol

    init(movieId: Int? = nil, movieService: MovieServiceProtocol = MovieService()) {
        self.movieService = movieService

        // If a movie ID is provided, fetch the details immediately
        if let id = movieId {
            Task {
                await fetchMovieDetails(id: id)
            }
        }
    }

    // Fetch detailed movie information
    func fetchMovieDetails(id: Int) async {
        isLoading = true
        errorMessage = nil

        do {
            let movieDetails = try await movieService.fetchMovieDetails(id: id)
            movie = movieDetails
            isLoading = false
        } catch {
            handleError(error)
        }
    }

    // Helper computed properties for formatting movie information

    var releaseDate: String {
        guard let releaseDateString = movie?.releaseDate,
              let date = DateFormatter.yyyyMMdd.date(from: releaseDateString) else {
            return "Release date unknown"
        }
        return DateFormatter.mediumDate.string(from: date)
    }

    var formattedRuntime: String {
        guard let runtime = movie?.runtime else {
            return "Runtime unknown"
        }

        let hours = runtime / 60
        let minutes = runtime % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    var genresList: String {
        guard let genres = movie?.genres, !genres.isEmpty else {
            return "Genres unknown"
        }

        return genres.map { $0.name }.joined(separator: ", ")
    }

    var ratingText: String {
        guard let rating = movie?.voteAverage else {
            return "Not rated"
        }
        return String(format: "%.1f/10", rating)
    }

    // Common error handling logic
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = networkError.errorMessage
        } else {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
