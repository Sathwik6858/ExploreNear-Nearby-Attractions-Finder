//
//  FavoritesView.swift
//  AttractionExplorer
//
//  Created by Sathwik Alasyam on 12/1/24.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var sessionManager: UserSessionManager
    @State private var favorites: [Attraction] = []
    @State private var searchQuery: String = "" // Search query state
    @State private var isLoading = false // Track loading state
    @State private var errorMessage: ErrorMessage? // Use Identifiable wrapper for error messages

    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                SearchBar(
                    searchText: $searchQuery,
                    onSearch: {
                        searchFavorites()
                    },
                    onCancel: {
                        searchQuery = ""
                        fetchFavorites() // Reset to all favorites when canceled
                    }
                )
                .padding()

                if isLoading {
                    // Show a loading spinner when data is being fetched
                    Spacer()
                    ProgressView("Loading Favorites...")
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                } else if favorites.isEmpty {
                    // Show message when no favorites are available
                    Spacer()
                    Text("No Favorites Yet")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    // Display list of favorites
                    List {
                        ForEach(favorites) { attraction in
                            VStack(alignment: .leading) {
                                Text(attraction.name)
                                    .font(.headline)
                                Text(attraction.description.isEmpty ? "N/A" : attraction.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("ZIP: \(attraction.zipcode)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 5)
                            
                            // Delete button
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    removeAttraction(attraction)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }

                Spacer()

                // Logout Button
                Button(action: {
                    logout()
                }) {
                    Text("Logout")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                .padding(.bottom, 30) // Add spacing at the bottom
            }
            .onAppear {
                fetchFavorites()
            }
            .navigationTitle("Favorites")
            .alert(item: $errorMessage) { message in
                Alert(title: Text("Error"), message: Text(message.text), dismissButton: .default(Text("OK")))
            }
        }
    }

    // MARK: - Fetch Favorites
    private func fetchFavorites() {
        guard !sessionManager.currentUserName.isEmpty else {
            errorMessage = ErrorMessage(text: "Error: No user logged in.")
            return
        }

        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let connection = PostgresConnection()
            let fetchedFavorites = connection.getFavoriteAttractions(userName: sessionManager.currentUserName)
            DispatchQueue.main.async {
                self.favorites = fetchedFavorites
                self.isLoading = false

                if fetchedFavorites.isEmpty {
                    self.errorMessage = ErrorMessage(text: "No favorites found for user \(sessionManager.currentUserName).")
                }
            }
        }
    }

    // MARK: - Search Favorites
    private func searchFavorites() {
        guard !searchQuery.isEmpty else {
            fetchFavorites() // Reset to all favorites if search query is empty
            return
        }

        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let filteredFavorites = favorites.filter { $0.zipcode.contains(searchQuery) }
            DispatchQueue.main.async {
                self.favorites = filteredFavorites
                self.isLoading = false

                if filteredFavorites.isEmpty {
                    self.errorMessage = ErrorMessage(text: "No favorites found for ZIP code \(searchQuery).")
                }
            }
        }
    }

    // MARK: - Remove Attraction
    private func removeAttraction(_ attraction: Attraction) {
        guard !sessionManager.currentUserName.isEmpty else {
            errorMessage = ErrorMessage(text: "Error: No user logged in.")
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let connection = PostgresConnection()
            connection.removeAttractionFromFavorites(userString: sessionManager.currentUserName, attractionID: attraction.attractionID)

            DispatchQueue.main.async {
                // Update the favorites list after removing
                fetchFavorites()
            }
        }
    }

    // MARK: - Logout
    private func logout() {
        // Reset session state
        sessionManager.currentUserName = ""
        sessionManager.isLoggedIn = false
    }
}

// MARK: - Identifiable Error Wrapper
struct ErrorMessage: Identifiable {
    let id = UUID() // Automatically conform to Identifiable
    let text: String
}

// MARK: - SearchBar Component
struct SearchBarr: View {
    @Binding var searchText: String
    var onSearch: () -> Void
    var onCancel: () -> Void

    var body: some View {
        HStack {
            TextField("Search by ZIP code", text: $searchText, onCommit: {
                onSearch()
            })
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
                HStack {
                    Spacer()
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            onCancel()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 8)
                        }
                    }
                }
            )
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview
struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
            .environmentObject(UserSessionManager()) // Mock environment object for preview
    }
}
