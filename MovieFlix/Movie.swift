//
//  Movie.swift
//  MovieFlix
//
//  Created by Royal K on 2025-02-24.
//

import Foundation

// Main movie model that matches the TMDB API response structure
struct Movie: Identifiable, Decodable {
    let id: Int
    let title: String
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double?
    let voteCount: Int?
    let genres: [Genre]?
    let runtime: Int?

    // Computed properties for formatting and convenience
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }

    var backdropURL: URL? {
        guard let backdropPath = backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w1280\(backdropPath)")
    }

    var releaseYear: String? {
        guard let releaseDateString = releaseDate,
              let date = DateFormatter.yyyyMMdd.date(from: releaseDateString) else {
            return nil
        }
        return DateFormatter.year.string(from: date)
    }

    var formattedRating: String {
        guard let rating = voteAverage else { return "N/A" }
        return String(format: "%.1f", rating)
    }

    // CodingKeys to map API response keys to our property names
    enum CodingKeys: String, CodingKey {
        case id, title, overview, genres, runtime
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

// Movie genre model
struct Genre: Identifiable, Decodable {
    let id: Int
    let name: String
}

// API response for movie lists
struct MovieResponse: Decodable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

// Date formatter extensions for convenience
extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static let year: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()

    static let mediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
