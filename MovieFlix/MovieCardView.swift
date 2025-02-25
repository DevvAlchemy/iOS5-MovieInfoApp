//
//  MovieCardView.swift
//  MovieFlix
//
//  Created by Royal K on 2025-02-25.
//

import SwiftUI

struct MovieCardView: View {
    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Poster Image
            Group {
                if let posterURL = movie.posterURL {
                    AsyncImage(url: posterURL) { phase in
                        switch phase {
                        case .empty:
                            RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    ProgressView()
                                        .tint(.gray)
                                )
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Image(systemName: "film")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    // No poster available
                    RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "film")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                }
            }
            .aspectRatio(2/3, contentMode: .fit)
            .frame(height: 180)
            .cornerRadius(Constants.UI.cornerRadius)
            .shadow(radius: 2)

            // Movie Title
            Text(movie.title)
                .font(.headline)
                .lineLimit(1)
                .foregroundColor(.primary)

            // Rating and Year
            HStack {
                // Rating (Star icon + rating value)
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)

                    Text(movie.formattedRating)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Release Year
                if let year = movie.releaseYear {
                    Text(year)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.systemBackground))
        .cornerRadius(Constants.UI.cornerRadius)
        .shadow(color: Color.black.opacity(0.1), radius: 5)
    }
}

struct MovieListItemView: View {
    let movie: Movie

    var body: some View {
        HStack(spacing: 15) {
            // Poster Image
            Group {
                if let posterURL = movie.posterURL {
                    AsyncImage(url: posterURL) { phase in
                        switch phase {
                        case .empty:
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .overlay(ProgressView())
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fill)
                        case .failure:
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Image(systemName: "film")
                                        .foregroundColor(.gray)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "film")
                                .foregroundColor(.gray)
                        )
                }
            }
            .frame(width: 80, height: 120)
            .cornerRadius(8)
            .shadow(radius: 2)

            // Movie details
            VStack(alignment: .leading, spacing: 5) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)

                if let year = movie.releaseYear {
                    Text(year)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)

                    Text(movie.formattedRating)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let overview = movie.overview, !overview.isEmpty {
                    Text(overview)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding(10)
        .background(Color(.systemBackground))
        .cornerRadius(Constants.UI.cornerRadius)
        .shadow(color: Color.black.opacity(0.1), radius: 2)
    }
}

struct MovieCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Preview both card and list item views
            VStack {
                MovieCardView(movie: previewMovie)
                    .frame(width: 160)

                MovieListItemView(movie: previewMovie)
                    .padding()
            }
            .padding()
            .previewLayout(.sizeThatFits)
        }
    }

    static var previewMovie: Movie {
        Movie(
            id: 550,
            title: "Fight Club",
            overview: "A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy.",
            posterPath: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
            backdropPath: "/hZkgoQYus5vegHoetLkCJzb17zJ.jpg",
            releaseDate: "1999-10-15",
            voteAverage: 8.4,
            voteCount: 24575,
            genres: [
                Genre(id: 18, name: "Drama")
            ],
            runtime: 139
        )
    }
}
