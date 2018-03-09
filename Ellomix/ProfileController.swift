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
    
    private var FirebaseAPI: FirebaseApi!
    var currentUser:EllomixUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseAPI = FirebaseApi()
        
        if (currentUser == nil) {
            // Viewing our profile
            currentUser = Global.sharedGlobal.user
            followButton.isHidden = true
            messageButton.isHidden = true
            editProfileButton.layer.cornerRadius = editProfileButton.frame.height / 2
        } else {
            // Viewing another user's profile
            editProfileButton.isHidden = true
            followButton.layer.cornerRadius = followButton.frame.height / 2
            messageButton.layer.cornerRadius = messageButton.frame.height / 2
            
            FirebaseAPI.getFollowingRef()
                .child((Global.sharedGlobal.user?.uid)!)
                .child((currentUser?.uid)!)
                .observe(.value, with: { (snapshot) in
                    if (snapshot.exists()) {
                        self.followButton.setTitle("Unfollow", for: .normal)
                    } else {
                        self.followButton.setTitle("Follow", for: .normal)
                    }
                }) { (error) in
                    print(error.localizedDescription)
                }
        }

        profilePic.clipsToBounds = true
    }

    override func viewDidAppear(_ animated: Bool) {
        loadProfile()
    }
    
    override func viewWillLayoutSubviews() {
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
    }
    
    func loadProfile() {
        navigationController?.navigationBar.topItem?.title = currentUser?.getName()
        profilePic.image = currentUser?.getProfilePicture().image
    }
    
    @IBAction func followUnfollowButtonClicked(_ sender: Any) {
        if (followButton.titleLabel?.text == "Follow") {
            
        } else {
            
        }
    }
    
    
    func logoutProfile() {
        let loginManager = LoginManager()
        //log off facebook
        loginManager.logOut()
        
        //log off firebase
        
        //segue into login screen on story board
        
    }
    
}
