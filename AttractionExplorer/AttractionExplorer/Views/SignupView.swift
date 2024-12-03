//
//  SignupView.swift
//  AttractionExplorer
//
//  Created by Sathwik Alasyam on 12/1/24.
//

import SwiftUI

struct SignupView: View {
    @State private var userName = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var zipCode = ""
    @State private var showAlert = false
    @State private var successMessage = ""
    @State private var navigateToLogin = false // Controls navigation

    var body: some View {
        VStack {
            Text("Sign Up").font(.largeTitle).padding()
            
            TextField("Username", text: $userName)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            
            TextField("First Name", text: $firstName)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            
            TextField("Last Name", text: $lastName)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            
            TextField("Email", text: $email)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            
            TextField("Phone Number", text: $phoneNumber)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            
            TextField("Fav ZipCode", text: $zipCode)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            
            Button("Sign Up") {
                let connection = PostgresConnection()
                connection.addUser(userName: userName, password: password, lastName: lastName, firstName: firstName, zipCode: zipCode, phoneNumber: phoneNumber, email: email)
                successMessage = "Account created successfully!"
                showAlert = true
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.green)
            .cornerRadius(10)
            .padding(.top)
            
            // Navigate back to LoginView when navigateToLogin is true
            NavigationLink("", destination: LoginView(), isActive: $navigateToLogin)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Success"),
                message: Text(successMessage),
                dismissButton: .default(Text("OK"), action: {
                    navigateToLogin = true // Trigger navigation
                })
            )
        }
    }
}
