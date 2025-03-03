//
//  MovieFlixViewModel.swift
//  MovieFlixWidgetExtension
//
//  Created by Royal K on 2025-03-02.
//

import Foundation
import WidgetKit
import SwiftUI

// This struct represents the data our widget will display
struct MovieWidgetData: Codable {
    let id: Int
    let title: String
    let posterPath: String?
    let releaseYear: String
    let rating: Double
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }

    // method to create widget data from our Movie model
    static func from(movie: Movie) -> MovieWidgetData {
        let year = movie.releaseYear ?? "N/A"
        let rating = movie.voteAverage ?? 0.0

        return MovieWidgetData(
            id: movie.id,
            title: movie.title,
            posterPath: movie.posterPath,
            releaseYear: year,
            rating: rating
        )
    }
}

// A manager class that handles fetching and storing widget data
class WidgetDataManager {
    // Singleton instance for when i need to manage access to a shared resource like a database connection, file system, or network manager.
    static let shared = WidgetDataManager()

    // Key for UserDefaults storage
    private let userDefaultsKey = "widget_trending_movies"

    // We'll cache the movies for the widget here
    private var cachedMovies: [MovieWidgetData] = []

    private init() {
        // Load any cached data when initialized
        loadFromUserDefaults()
    }

    // Get movies for the widget - either from cache or defaults
    func getTrendingMovies() -> [MovieWidgetData] {
        return cachedMovies
    }

    // Update the cache with new movies and save to UserDefaults
    func updateTrendingMovies(movies: [Movie]) {
        let widgetMovies = movies.prefix(5).map { MovieWidgetData.from(movie: $0) }
        self.cachedMovies = Array(widgetMovies)
        saveToUserDefaults()

        // Tell WidgetKit to refresh the widget timeline
        WidgetCenter.shared.reloadAllTimelines()
    }

    // Save the current movie data to UserDefaults
    private func saveToUserDefaults() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(cachedMovies)
            UserDefaults(suiteName: "group.com.DevvAlchemy.MovieFlix")?.set(data, forKey: userDefaultsKey)
        } catch {
            print("Failed to save widget data: \(error.localizedDescription)")
        }
    }

    // Load movie data from UserDefaults
    private func loadFromUserDefaults() {
        guard let data = UserDefaults(suiteName: "group.com.yourcompany.MovieFlix")?.data(forKey: userDefaultsKey) else {
            return
        }

        do {
            let decoder = JSONDecoder()
            cachedMovies = try decoder.decode([MovieWidgetData].self, from: data)
        } catch {
            print("Failed to load widget data: \(error.localizedDescription)")
        }
    }
}
