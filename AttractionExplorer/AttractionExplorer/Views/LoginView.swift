//
//  LoginView.swift
//  AttractionExplorer
//
//  Created by Sathwik Alasyam on 12/1/24.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userSession: UserSessionManager // Use the environment object
    @State private var userName: String = ""
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var errorMessage = ""
    @State private var keyboardOffset: CGFloat = 0 // Track keyboard offset

    var body: some View {
        NavigationView {
            ZStack {
                // Background Image
                Image("backgroundImage") // Replace with your image asset name
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)

                // Semi-Transparent Overlay
                Color.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // Welcome Title and Tagline at the Top
                    VStack(spacing: 10) {
                        Text("Welcome to\nAttractions Near You")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text("Discover amazing attractions in your area!")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)

                    Spacer()
                    Spacer()
                    Spacer()

                    // Login Form
                    VStack(spacing: 20) {
                        TextField("Enter your Username", text: $userName)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.9)))
                            .foregroundColor(.black)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .frame(maxWidth: 350)

                        SecureField("Enter your Password", text: $password)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.9)))
                            .foregroundColor(.black)
                            .frame(maxWidth: 350)

                        Button(action: {
                            let connection = PostgresConnection()
                            let userExists = connection.authenticateUser(userName: userName, password: password)

                            if userExists {
                                userSession.currentUserName = userName
                                userSession.isLoggedIn = true
                            } else {
                                showAlert = true
                                errorMessage = "Invalid username or password"
                            }
                        }) {
                            Text("Login")
                                .fontWeight(.bold)
                                .frame(maxWidth: 350)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 20)

                    // Sign-Up Prompt
                    VStack {
                        Text("Don't have an account?")
                            .foregroundColor(.white)

                        NavigationLink(destination: SignupView()) {
                            Text("Create an account by signing up.")
                                .foregroundColor(.blue)
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.top, 30)

                    Spacer()
                }
                .offset(y: -keyboardOffset)
                .animation(.easeOut, value: keyboardOffset)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                registerForKeyboardNotifications()
            }
            .onDisappear {
                removeKeyboardNotifications()
            }
        }
    }

    // MARK: - Keyboard Handling
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardOffset = keyboardFrame.height / 2
            }
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            keyboardOffset = 0
        }
    }

    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: - PreviewProvider
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(UserSessionManager())
    }
}
