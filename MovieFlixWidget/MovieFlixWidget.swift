//
//  MovieFlixWidget.swift
//  MovieFlixWidget
//
//  Created by Royal K on 2025-03-02.
//

import WidgetKit
import SwiftUI

// The entry point of our widget
struct MovieFlixWidget: Widget {
    // The kind identifier is a unique string that identifies our widget
    let kind: String = "MovieFlixWidget"

    // Configuration of the widget including name and description
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MovieProvider()) { entry in
            MovieFlixWidgetEntryView(entry: entry)
        }
        // Configure the display name and description shown in the widget gallery
        .configurationDisplayName("Trending Movies")
        .description("Stay updated with the latest trending movies.")
        // Configure the supported widget sizes
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// The provider determines when to update the widget and provides the data
struct MovieProvider: TimelineProvider {
    // Provides a placeholder to show while the widget is loading
    func placeholder(in context: Context) -> MovieEntry {
        MovieEntry(date: Date(), movies: placeholderMovies)
    }

    // A snapshot for the widget gallery
    func getSnapshot(in context: Context, completion: @escaping (MovieEntry) -> ()) {
        let movies = WidgetDataManager.shared.getTrendingMovies()

        // If we have cached movies, use them. Otherwise, use placeholders
        if !movies.isEmpty {
            let entry = MovieEntry(date: Date(), movies: movies)
            completion(entry)
        } else {
            let entry = MovieEntry(date: Date(), movies: placeholderMovies)
            completion(entry)
        }
    }

    // Get the timeline of entries for the widget to update
    func getTimeline(in context: Context, completion: @escaping (Timeline<MovieEntry>) -> ()) {
        let movies = WidgetDataManager.shared.getTrendingMovies()

        // Create a single entry with current data
        let entry = MovieEntry(date: Date(), movies: movies.isEmpty ? placeholderMovies : movies)

        // Update the widget every hour
        let nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))

        completion(timeline)
    }

    // Placeholder movie data for when real data isn't available yet
    private var placeholderMovies: [MovieWidgetData] {
        return [
            MovieWidgetData(
                id: 1,
                title: "The Shawshank Redemption",
                posterPath: nil,
                releaseYear: "1994",
                rating: 9.3
            ),
            MovieWidgetData(
                id: 2,
                title: "The Godfather",
                posterPath: nil,
                releaseYear: "1972",
                rating: 9.2
            ),
            MovieWidgetData(
                id: 3,
                title: "The Dark Knight",
                posterPath: nil,
                releaseYear: "2008",
                rating: 9.0
            )
        ]
    }
}

// The entry represents a single moment in time for the widget
struct MovieEntry: TimelineEntry {
    let date: Date
    let movies: [MovieWidgetData]
}
