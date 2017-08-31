//
//  User.swift
//  Ellomix
//
//  Created by Kevin Avila on 8/27/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import Foundation

class User {
    
    var uid = ""
    var firstName:String = ""
    var lastName:String = ""
    
    init(uid: String) {
        self.uid = uid
    }
    
    func setFirstName(firstName: String) {
        self.firstName = firstName
    }
    
    func setLastName(lastName: String) {
        self.lastName = lastName
    }
    
    func getFirstName() -> String {
        return firstName
    }
    
    func getLastName() -> String {
        return lastName
    }
    
    func toDictionary() -> Any {
        let name = firstName + " " + lastName
        return ["uid": uid, "name": name]
    }
}
