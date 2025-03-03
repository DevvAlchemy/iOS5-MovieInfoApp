//
//  MovieFlixWidgetViews.swift
//  MovieFlixWidgetExtension
//
//  Created by Royal K on 2025-03-02.
//

import SwiftUI
import WidgetKit

// The main view for our widget
struct MovieFlixWidgetEntryView: View {
    // Get current color scheme (dark/light mode)
    @Environment(\.colorScheme) var colorScheme
    // The entry containing the data to display
    var entry: MovieProvider.Entry
    // Get the widget family (size)
    @Environment(\.widgetFamily) var family

    var body: some View {
        // Choose layout based on widget size
        switch family {
        case .systemSmall:
            SmallWidgetView(movie: entry.movies.first ?? placeholderMovie)
        case .systemMedium:
            MediumWidgetView(movies: entry.movies)
        default:
            // Fallback for any unsupported sizes
            Text("Widget size not supported")
        }
    }

    // Fallback movie if no data is available
    private var placeholderMovie: MovieWidgetData {
        MovieWidgetData(
            id: 0,
            title: "No movies available",
            posterPath: nil,
            releaseYear: "--",
            rating: 0.0
        )
    }
}

// For the small widget size - shows a single trending movie
struct SmallWidgetView: View {
    let movie: MovieWidgetData
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // Background poster or gradient
            if let posterURL = movie.posterURL {
                // Use poster image as background if available
                AsyncImage(url: posterURL) { phase in
                    if let image = phase.image {
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        // Show gradient while loading or if image fails
                        movieGradient
                    }
                }
            } else {
                // Default gradient if no poster
                movieGradient
            }

            Rectangle()
                .fill(Color.black.opacity(0.5))

            // Content
            VStack(alignment: .leading, spacing: 4) {
                // Header with app name
                HStack {
                    Text("MovieFlix")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Spacer()

                    // "Trending" badge
                    Text("TRENDING")
                        .font(.system(size: 8))
                        .fontWeight(.semibold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }

                Spacer()

                // Movie title
                Text(movie.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .shadow(radius: 1)

                // Year and rating
                HStack {
                    Text(movie.releaseYear)
                        .font(.caption2)
                        .foregroundColor(.white)

                    Spacer()

                    // Rating with star icon
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)

                        Text(String(format: "%.1f", movie.rating))
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(12)
        }
        // Link to open the app when tapped
        .widgetURL(URL(string: "movieflix://movie/\(movie.id)"))
    }

    // Gradient background for when no poster is available
    private var movieGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [.blue, .purple]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// For the medium widget size - shows multiple trending movies
struct MediumWidgetView: View {
    let movies: [MovieWidgetData]
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading) {
            // Header
            HStack {
                Text("Trending on MovieFlix")
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 4)

            // Movie carousel/list
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Display up to 5 movie posters
                    ForEach(movies.prefix(5), id: \.id) { movie in
                        MovieCardView(movie: movie)
                    }

                    // If we have fewer than 5 movies, add placeholder cards
                    if movies.count < 5 {
                        ForEach(0..<(5 - movies.count), id: \.self) { _ in
                            MoviePlaceholderCard()
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
        // Link to open the app's main screen when tapped
        .widgetURL(URL(string: "movieflix://trending"))
    }
}

// Individual movie card for the medium widget
struct MovieCardView: View {
    let movie: MovieWidgetData

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Movie poster
            ZStack {
                if let posterURL = movie.posterURL {
                    AsyncImage(url: posterURL) { phase in
                        if let image = phase.image {
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            posterPlaceholder
                        }
                    }
                    .aspectRatio(2/3, contentMode: .fit)
                    .cornerRadius(8)
                } else {
                    posterPlaceholder
                }
            }
            .frame(width: 65, height: 95)
            .cornerRadius(8)
            .shadow(radius: 2)

            // Rating
            HStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .font(.system(size: 8))
                    .foregroundColor(.yellow)

                Text(String(format: "%.1f", movie.rating))
                    .font(.system(size: 10))
                    .fontWeight(.medium)
            }
            .padding(.top, 2)

            // We don't include the title in medium widget cards to keep them compact
        }
        .frame(width: 65)
        // Link to open this specific movie when tapped
        .widgetURL(URL(string: "movieflix://movie/\(movie.id)"))
    }

    // Placeholder for when poster image isn't available
    private var posterPlaceholder: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .overlay(
                Image(systemName: "film")
                    .font(.title3)
                    .foregroundColor(.gray)
            )
            .aspectRatio(2/3, contentMode: .fit)
            .cornerRadius(8)
    }
}

// Placeholder card when we don't have enough movies
struct MoviePlaceholderCard: View {
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(width: 65, height: 95)
            .cornerRadius(8)
            .overlay(
                Image(systemName: "film")
                    .font(.title3)
                    .foregroundColor(.gray.opacity(0.5))
            )
    }
}

// Preview for the widget
struct MovieFlixWidget_Previews: PreviewProvider {
    // Sample movie data for previews
    static var sampleMovies: [MovieWidgetData] = [
        MovieWidgetData(
            id: 1,
            title: "The Shawshank Redemption",
            posterPath: "/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg",
            releaseYear: "1994",
            rating: 9.3
        ),
        MovieWidgetData(
            id: 2,
            title: "The Godfather",
            posterPath: "/3bhkrj58Vtu7enYsRolD1fZdja1.jpg",
            releaseYear: "1972",
            rating: 9.2
        ),
        MovieWidgetData(
            id: 3,
            title: "The Dark Knight",
            posterPath: "/qJ2tW6WMUDux911r6m7haRef0WH.jpg",
            releaseYear: "2008",
            rating: 9.0
        ),
        MovieWidgetData(
            id: 4,
            title: "Pulp Fiction",
            posterPath: "/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg",
            releaseYear: "1994",
            rating: 8.9
        ),
        MovieWidgetData(
            id: 5,
            title: "Fight Club",
            posterPath: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
            releaseYear: "1999",
            rating: 8.8
        )
    ]

    static var previews: some View {
        // Preview small widget
        MovieFlixWidgetEntryView(entry: MovieEntry(date: Date(), movies: sampleMovies))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDisplayName("Small Widget")

        // Preview medium widget
        MovieFlixWidgetEntryView(entry: MovieEntry(date: Date(), movies: sampleMovies))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .previewDisplayName("Medium Widget")
    }
}
