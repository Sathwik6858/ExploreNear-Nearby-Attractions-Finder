//
//  User.swift
//  AttractionExplorer
//
//  Created by Sathwik Alasyam on 12/1/24.
//

import Foundation

struct User: Identifiable {
    var id: String { userName }
    var userName: String
    var email: String
    var phoneNumber: String
    var password: String
}
