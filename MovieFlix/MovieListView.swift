//
//  MovieListView.swift
//  MovieFlix
//
//  Created by Royal K on 2025-02-25.
//

import SwiftUI

struct MovieListView: View {
    @StateObject private var viewModel = MovieListViewModel()
    @State private var showingSearch = false

    var body: some View {
        NavigationView {
            ZStack {
                // Main content
                VStack {
                    // Popular Movies Grid
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 160), spacing: Constants.UI.cardSpacing)
                        ], spacing: Constants.UI.cardSpacing) {
                            ForEach(viewModel.movies) { movie in
                                NavigationLink(destination: MovieDetailView(movieId: movie.id)) {
                                    MovieCardView(movie: movie)
                                        .task {
                                            // Pagination - load more when reaching near the end
                                            await viewModel.loadMoreIfNeeded(currentMovie: movie)
                                        }
                                }
                            }
                        }
                        .padding()

                        // Footer with loading indicator or end of content message
                        if viewModel.isLoading && !viewModel.movies.isEmpty {
                            ProgressView()
                                .padding()
                        }
                    }
                }

                // Overlay for loading or error state
                if viewModel.movies.isEmpty {
                    if viewModel.isLoading {
                        LoadingView()
                    } else if let errorMessage = viewModel.errorMessage {
                        ErrorView(message: errorMessage) {
                            Task {
                                await viewModel.loadPopularMovies()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Popular Movies")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSearch = true }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .sheet(isPresented: $showingSearch) {
                SearchView(viewModel: viewModel)
            }
            .task {
                if viewModel.movies.isEmpty {
                    await viewModel.loadPopularMovies()
                }
            }
        }
    }
}

struct SearchView: View {
    @ObservedObject var viewModel: MovieListViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isSearchFieldFocused: Bool

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    // Search field
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)

                        TextField("Search for movies...", text: $viewModel.searchQuery)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .focused($isSearchFieldFocused)
                            .submitLabel(.search)
                            .onSubmit {
                                Task {
                                    await viewModel.searchMovies()
                                }
                            }

                        if !viewModel.searchQuery.isEmpty {
                            Button(action: {
                                viewModel.clearSearch()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // Search results
                    if viewModel.searchQuery.isEmpty {
                        EmptySearchView()
                    } else if viewModel.isLoading {
                        LoadingView()
                    } else if let errorMessage = viewModel.errorMessage {
                        ErrorView(message: errorMessage) {
                            Task {
                                await viewModel.searchMovies()
                            }
                        }
                    } else if viewModel.searchResults.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)

                            Text("No movies found for '\(viewModel.searchQuery)'")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // Show search results in a list
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.searchResults) { movie in
                                    NavigationLink(destination: MovieDetailView(movieId: movie.id)) {
                                        MovieListItemView(movie: movie)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding()
                        }
                    }
                }

                // Bottom navigation bar
                VStack {
                    Spacer()

                    Button(action: {
                        dismiss()
                    }) {
                        Text("Close")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Search Movies")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                isSearchFieldFocused = true
            }
            .onChange(of: viewModel.searchQuery) { newValue in
                if !newValue.isEmpty {
                    Task {
                        await viewModel.searchMovies()
                    }
                }
            }
        }
    }
}

struct MovieListView_Previews: PreviewProvider {
    static var previews: some View {
        MovieListView()
    }
}
