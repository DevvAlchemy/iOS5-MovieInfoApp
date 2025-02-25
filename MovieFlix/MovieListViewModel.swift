//
//  MovieListViewModel.swift
//  MovieFlix
//
//  Created by Royal K on 2025-02-25.
//

import Foundation
import SwiftUI

@MainActor
class MovieListViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var searchResults: [Movie] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var searchQuery = ""

    // Pagination tracking
    private var currentPage = 1
    private var hasMorePages = true
    private var isFetchingData = false

    private let movieService: MovieServiceProtocol

    init(movieService: MovieServiceProtocol = MovieService()) {
        self.movieService = movieService
    }

    // Load initial popular movies when the app starts
    func loadPopularMovies() async {
        guard !isFetchingData && (movies.isEmpty || hasMorePages) else { return }

        isLoading = true
        isFetchingData = true
        errorMessage = nil

        do {
            let response = try await movieService.fetchPopularMovies(page: currentPage)

            // Add new movies to the existing list
            movies.append(contentsOf: response.results)

            // Update pagination state
            currentPage += 1
            hasMorePages = currentPage <= response.totalPages

            isLoading = false
            isFetchingData = false
        } catch {
            handleError(error)
        }
    }

    // Search for movies
    func searchMovies() async {
        // Don't search if query is empty
        guard !searchQuery.isEmpty else {
            searchResults = []
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await movieService.searchMovies(query: searchQuery, page: 1)
            searchResults = response.results
            isLoading = false
        } catch {
            handleError(error)
        }
    }

    // Called when user reaches the end of the list to load more content
    func loadMoreIfNeeded(currentMovie movie: Movie) async {
        // If we're viewing the last few items and there are more pages, load more
        let thresholdIndex = movies.index(movies.endIndex, offsetBy: -5)
        if movies.firstIndex(where: { $0.id == movie.id }) ?? 0 >= thresholdIndex && hasMorePages {
            await loadPopularMovies()
        }
    }

    // Reset search results
    func clearSearch() {
        searchQuery = ""
        searchResults = []
    }

    // Common error handling logic
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = networkError.errorMessage
        } else {
            errorMessage = error.localizedDescription
        }
        isLoading = false
        isFetchingData = false
    }
}
