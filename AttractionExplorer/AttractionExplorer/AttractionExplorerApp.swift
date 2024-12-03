//
//  AttractionExplorerApp.swift
//  AttractionExplorer
//
//  Created by Ben Ashkenazi on 10/24/24.
//

import SwiftUI

@main
struct AttractionExplorerApp: App {
    @StateObject var userSession = UserSessionManager() // Create a shared session manager

    var body: some Scene {
        WindowGroup {
            if userSession.isLoggedIn { // Correct way to access `isLoggedIn`
                MainTabView()
                    .environmentObject(userSession)
            } else {
                LoginView()
                    .environmentObject(userSession)
            }
        }
    }
}

