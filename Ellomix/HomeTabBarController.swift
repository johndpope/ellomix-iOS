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
    private var user: FIRUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseAPI = FirebaseApi()
        user = FIRAuth.auth()!.currentUser!
        
        FirebaseAPI.getUsersRef().observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            if (snapshot.hasChild(self.user.uid)) {
                print("User was loaded from Firbase")

            } else {
                // Initialize new user
                self.fetchProfile(user: self.user)
            }
        })
    }
    
    func fetchProfile(user: FIRUser) {
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
                                
                                let newUser = User(uid: user.uid)
                                newUser.setFirstName(firstName: firstName!)
                                newUser.setLastName(lastName: lastName!)
                                
                                if let picture = responseDict["picture"] as? NSDictionary {
                                    if let data = picture["data"] as? NSDictionary {
                                        if let url = data["url"] as? String {
                                            
                                            // download image from url
                                            //self.profilePictureImageView.downloadedFrom(link: url)
                                        }
                                    }
                                }
                                self.FirebaseAPI.createUser(user: newUser)
                            }
                            
                            break
                        }
                        
        }
    }
}

//CODE To display profile pictue ETC ignore imgview and you can just reuse code--

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
    
}
