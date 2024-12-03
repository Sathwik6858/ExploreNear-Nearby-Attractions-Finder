//
//  UserSessionManager.swift
//  AttractionExplorer
//
//  Created by Sathwik Alasyam on 12/1/24.
//

import Combine

class UserSessionManager: ObservableObject {
    @Published var isLoggedIn: Bool = false // Track login status
    @Published var currentUserName: String = "" // Track current username

    // Simulate a login function
    func login(userName: String) {
        self.currentUserName = userName
        self.isLoggedIn = true
    }

    // Simulate a logout function
    func logout() {
        self.currentUserName = ""
        self.isLoggedIn = false
    }
}
