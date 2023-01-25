//
//  User.swift
//  UberTutorial
//
//  Created by Dmytro Grytsenko on 25.01.2023.
//

struct User {
    
    let fullname: String
    let email: String
    let accountType: Int
    
    init(dictionary: [String: Any]) {
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.accountType = dictionary["accountType"] as? Int ?? 0
    }
}

