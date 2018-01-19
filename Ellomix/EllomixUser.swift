//
//  User.swift
//  Ellomix
//
//  Created by Kevin Avila on 8/27/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import Foundation
import UIKit

class EllomixUser {
    
    var uid = ""
    var name:String = ""
    var profilePicLink:String = ""
    var profilePicture:UIImageView = UIImageView()
    var website:String = ""
    var bio:String = ""
    var email:String = ""
    var gender:String = ""
    var birthday:String = ""
    var password:String = ""
    
    init(uid: String) {
        self.uid = uid
    }
    
    func setName(name: String) {
        self.name = name
    }
    
    func setProfilePicLink(link: String) {
        self.profilePicLink = link
    }
    
    func setProfilePic(image: UIImage) {
        self.profilePicture.image = image;
    }
    
    func setWebsite(website: String) {
        self.website = website
    }
    
    func setBio(bio: String) {
        self.bio = bio
    }
    
    func setEmail(email: String) {
        self.email = email
    }
    
    func setGender(gender: String) {
        self.gender = gender
    }
    
    func setBirthday(birthday: String) {
        self.birthday = birthday
    }
    
    func setPassword(password: String) {
        self.password = password
    }

    func getName() -> String {
        return name
    }
    
    func getProfilePicture() -> UIImageView {
        return profilePicture
    }
    
    func getWebsite() -> String {
        return website
    }
    
    func getBio() -> String {
        return bio
    }
    
    func getEmail() -> String {
        return email
    }
    
    func getGender() -> String {
        return gender
    }
    
    func getBirthday() -> String {
        return birthday
    }
    
    func toDictionary() -> Any {
        var password = self.password
        if (password.isEmpty) {
            password = "N/A"
        }

        return ["uid": uid, "name": name, "photo_url": profilePicLink, "website": website, "bio": bio, "email": email, "gender": gender, "password": password]
    }
}
