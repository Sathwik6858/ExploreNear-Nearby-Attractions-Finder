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

    var body: some View {
        NavigationView {
            VStack {
                if favorites.isEmpty {
                    Spacer()
                    Text("No Favorites Yet")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    List(favorites) { attraction in
                        VStack(alignment: .leading) {
                            Text(attraction.name)
                                .font(.headline)
                            Text(attraction.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 5)
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
        }
    }

    private func fetchFavorites() {
        guard !sessionManager.currentUserName.isEmpty else {
            print("Error: No user logged in.")
            return
        }

        let connection = PostgresConnection()
        let fetchedFavorites = connection.getFavoriteAttractions(userName: sessionManager.currentUserName)
        self.favorites = fetchedFavorites
    }

    private func logout() {
        // Reset session state
        sessionManager.currentUserName = ""
        sessionManager.isLoggedIn = false
    }
}

// MARK: - Preview
struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
            .environmentObject(UserSessionManager()) // Mock environment object for preview
    }
}
