//
//  HomeTabController.swift
//  Ellomix
//
//  Created by Kevin Avila on 8/30/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FirebaseAuth

class HomeTabBarController: UITabBarController {
    
    private var FirebaseAPI: FirebaseApi!
    private var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseAPI = FirebaseApi()
        user = Auth.auth().currentUser!
        
        FirebaseAPI.getUsersRef().observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            if (snapshot.hasChild(self.user.uid)) {
                print("User was loaded from Firebase")
                
                let results = snapshot.value as! Dictionary<String, AnyObject>
                let userData = results[self.user.uid] as! Dictionary<String, AnyObject>
                
                self.setUser(userData: userData)

            } else {
                // Initialize new user
                self.fetchProfile(user: self.user)
            }
        })
    }
    
    func setUser(userData: Dictionary<String, AnyObject>) {
        print("userData: \(userData)")
        
        let name = userData["name"] as? String
        let photoUrl = userData["photo_url"] as? String
        let website = userData["website"] as? String
        let bio = userData["bio"] as? String
        let email = userData["email"] as? String
        let gender = userData["gender"] as? String
        
        let loadedUser = EllomixUser(uid: self.user.uid)
        loadedUser.setName(name: name!)
        loadedUser.profilePicture.downloadedFrom(link: photoUrl!)
        loadedUser.setProfilePicLink(link: photoUrl!)
        if (website != nil) { loadedUser.setWebsite(website: website!) }
        if (bio != nil) { loadedUser.setBio(bio: bio!) }
        if (email != nil) { loadedUser.setEmail(email: email!) }
        if (gender != nil) { loadedUser.setGender(gender: gender!) }
        Global.sharedGlobal.user = loadedUser
    }
    
    func fetchProfile(user: User) {
        let parameters = ["fields": "email, first_name, last_name, picture.type(large)"]
        print("Fetching profile from Facebook.")
        GraphRequest(graphPath: "me",
                     parameters: parameters,
                     accessToken: AccessToken.current,
                     httpMethod: .GET,
                     apiVersion: .defaultVersion).start { (urlResponse, requestResult) in
                        
                        switch requestResult {
                        case .failed(let error):
                            print(error)
                            break
                        case .success(let graphResponse):
                            
                            if let responseDict = graphResponse.dictionaryValue {
                                let firstName = responseDict["first_name"] as? String
                                let lastName = responseDict["last_name"] as? String
                                let name = firstName! + " " + lastName!
                                
                                let newUser = EllomixUser(uid: user.uid)
                                newUser.setName(name: name)
                                
                                if let picture = responseDict["picture"] as? NSDictionary {
                                    if let data = picture["data"] as? NSDictionary {
                                        if let url = data["url"] as? String {
                                            newUser.profilePicture.downloadedFrom(link: url)
                                            newUser.setProfilePicLink(link: url)
                                        }
                                    }
                                }
                                self.FirebaseAPI.updateUser(user: newUser)
                                Global.sharedGlobal.user = newUser
                            }
                            
                            break
                        }
                        
        }
    }
}
