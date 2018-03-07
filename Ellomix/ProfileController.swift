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
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var editProfileButton: UIButton!
    
    var currentUser:EllomixUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (currentUser == nil) {
            currentUser = Global.sharedGlobal.user
            followButton.isHidden = true
            messageButton.isHidden = true
        } else {
            editProfileButton.isHidden = true
        }
        
        followButton.layer.cornerRadius = followButton.frame.height / 2
        messageButton.layer.cornerRadius = messageButton.frame.height / 2
        editProfileButton.layer.cornerRadius = editProfileButton.frame.height / 2
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
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
