//
//  PreferencesManager.swift
//  AttractionExplorer
//
//  Created by Ben Ashkenazi on 12/5/24.
//

import Foundation

class PreferencesManager {
    static let shared = PreferencesManager()
    
    init() {}
    
    private let zipcodeKey = "favorite_zipcode"
    
    func saveZipcode(_ zipcode: String) {
        UserDefaults.standard.set(zipcode, forKey: zipcodeKey)
        
        UserDefaults.standard.synchronize()
    }
    
    func getZipcode() -> String? {
        return UserDefaults.standard.string(forKey: zipcodeKey)
    }
    
    func clearZipcode() {
        UserDefaults.standard.removeObject(forKey: zipcodeKey)
    }
}
