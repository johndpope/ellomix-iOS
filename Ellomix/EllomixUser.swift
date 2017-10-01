//
//  User.swift
//  Ellomix
//
//  Created by Kevin Avila on 8/27/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import Foundation
import UIKit

class User {
    
    var uid = ""
    var firstName:String = ""
    var lastName:String = ""
    var profilePicLink:String = ""
    var profilePicture:UIImageView = UIImageView()
    
    init(uid: String) {
        self.uid = uid
    }
    
    func setFirstName(firstName: String) {
        self.firstName = firstName
    }
    
    func setLastName(lastName: String) {
        self.lastName = lastName
    }
    
    func setProfilePicLink(link: String) {
        self.profilePicLink = link
    }
    
    func getFirstName() -> String {
        return firstName
    }
    
    func getLastName() -> String {
        return lastName
    }
    
    func getProfilePicture() -> UIImageView {
        return profilePicture
    }
    
    func toDictionary() -> Any {
        return ["uid": uid, "first_name": firstName, "last_name": lastName, "photo_url": profilePicLink]
    }
}
