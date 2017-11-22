//
//  ProfileController.swift
//  Ellomix
//
//  Created by Kevin Avila on 4/18/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FirebaseAuth
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class ProfileController: UIViewController {
    
    @IBOutlet weak var profilePic: UIImageView!
    
    var currentUser:EllomixUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = Global.sharedGlobal.user
    }

    override func viewDidAppear(_ animated: Bool) {
        loadProfile()
    }
    
    func loadProfile() {
        navigationController?.navigationBar.topItem?.title = currentUser?.getName()
        profilePic.image = currentUser?.getProfilePicture().image
    }
    
    func logoutProfile() {
        let loginManager = LoginManager()
        //log off facebook
        loginManager.logOut()
        
        //log off firebase
        
        //segue into login screen on story board
        
    }
    
}
