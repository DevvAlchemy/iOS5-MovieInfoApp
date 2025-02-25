//
//  MovieDetailView.swift
//  MovieFlix
//
//  Created by Royal K on 2025-02-25.
//

import SwiftUI

struct MovieDetailView: View {
    @StateObject private var viewModel: MovieDetailViewModel

    init(movieId: Int) {
        _viewModel = StateObject(wrappedValue: MovieDetailViewModel(movieId: movieId))
    }

    var body: some View {
        ScrollView {
            ZStack {
                VStack(alignment: .leading, spacing: 0) {
                    // Backdrop + Poster header section
                    headerSection

                    // Movie details
                    detailsSection
                        .padding(.top, 20)

                    // Overview section
                    overviewSection
                        .padding(.top, 30)
                }

                // Overlay loading or error views when needed
                if viewModel.isLoading {
                    LoadingView()
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage) {
                        if let id = viewModel.movie?.id {
                            Task {
                                await viewModel.fetchMovieDetails(id: id)
                            }
                        }
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header Section
    private var headerSection: some View {
        ZStack(alignment: .bottom) {
            // Backdrop image
            Group {
                if let backdropURL = viewModel.movie?.backdropURL {
                    AsyncImage(url: backdropURL) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
            }
            .frame(height: 250)
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.1),
                        Color.black.opacity(0.5)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            // Poster and title overlay at bottom of backdrop
            HStack(alignment: .bottom, spacing: 16) {
                // Poster
                Group {
                    if let posterURL = viewModel.movie?.posterURL {
                        AsyncImage(url: posterURL) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay(ProgressView())
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure:
                                Rectangle()
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
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                    }
                }
                .frame(width: 110, height: 160)
                .cornerRadius(10)
                .shadow(radius: 5)

                // Title and year
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.movie?.title ?? "")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 2)

                    if let year = viewModel.movie?.releaseYear {
                        Text(year)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .shadow(radius: 2)
                    }

                    if let rating = viewModel.movie?.voteAverage {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)

                            Text(String(format: "%.1f", rating))
                                .foregroundColor(.white)

                            if let voteCount = viewModel.movie?.voteCount {
                                Text("(\(voteCount))")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
    }

    // MARK: - Details Section
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section title
            Text("Details")
                .font(.headline)
                .padding(.horizontal, 30)


            // Details cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    // Release date card
                    detailCard(
                        iconName: "calendar",
                        title: "Release",
                        value: viewModel.releaseDate
                    )

                    // Runtime card
                    detailCard(
                        iconName: "clock",
                        title: "Runtime",
                        value: viewModel.formattedRuntime
                    )

                    // Rating card
                    detailCard(
                        iconName: "star.fill",
                        title: "Rating",
                        value: viewModel.ratingText,
                        iconColor: .yellow
                    )

                    // Genres card
                    detailCard(
                        iconName: "tag",
                        title: "Genre",
                        value: viewModel.genresList
                    )
                }
                .padding(.horizontal)
            }
        }
    }

    // Helper for creating detail cards
    private func detailCard(iconName: String, title: String, value: String, iconColor: Color = .blue) -> some View {
        VStack(alignment: .center, spacing: 10) {
            // Icon
            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundColor(iconColor)

            // Title
            Text(title)
                .font(.headline)
                .fontWeight(.medium)

            // Value
            Text(value)
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(width: 120, height: 120)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }

    // MARK: - Overview Section
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section title
            Text("Overview")
                .font(.title2)
                .fontWeight(.medium)
                .padding(.horizontal, 30)
                .padding(.top, 10)

            // Overview content
            if let overview = viewModel.movie?.overview, !overview.isEmpty {
                Text(overview)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
            } else {
                Text("No overview available.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.horizontal)
            }
        }
        .padding(.bottom, 30)
    }
}

struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MovieDetailView(movieId: 550) // Fight Club ID
        }
    }
}
