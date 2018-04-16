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
    @IBOutlet weak var followersCountButton: UIButton!
    @IBOutlet weak var followingCountButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var Settings_Button: UIBarButtonItem!
    
    private var FirebaseAPI: FirebaseApi!
    var currentUser:EllomixUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseAPI = FirebaseApi()
        
        if (currentUser == nil) {
            // Viewing our profile
            currentUser = Global.sharedGlobal.user
            Settings_Button.isEnabled = true
            followButton.isHidden = true
            messageButton.isHidden = true
            editProfileButton.layer.cornerRadius = editProfileButton.frame.height / 2
        } else {
            // Viewing another user's profile
            editProfileButton.isHidden = true
            Settings_Button.isEnabled = false
            followButton.layer.cornerRadius = followButton.frame.height / 2
            messageButton.layer.cornerRadius = messageButton.frame.height / 2
            
            FirebaseAPI.getFollowingRef()
                .child((Global.sharedGlobal.user?.uid)!)
                .child((currentUser?.uid)!)
                .observe(.value, with: { (snapshot) in
                    if (snapshot.exists()) {
                        self.followButton.setTitle("Unfollow", for: .normal)
                        self.messageButton.isEnabled = true
                        self.messageButton.alpha = 1.0
                    } else {
                        self.followButton.setTitle("Follow", for: .normal)
                        self.messageButton.isEnabled = false
                        self.messageButton.alpha = 0.5
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
        
        var followersCount:Int?
        var followingCount:Int?
        
        if (currentUser?.getFollowersCount() == nil) {
            followersCount = 0
        } else {
            followersCount = currentUser?.getFollowersCount()
        }
        
        if (currentUser?.getFollowingCount() == nil) {
            followingCount = 0
        } else {
            followingCount = currentUser?.getFollowingCount()
        }

        followersCountButton.setTitle(String(describing: followersCount!), for: .normal)
        followingCountButton.setTitle(String(describing: followingCount!), for: .normal)
    }
    
    @IBAction func followUnfollowButtonClicked(_ sender: Any) {
        let followersPath = "Followers/\((self.currentUser?.uid)!)/\((Global.sharedGlobal.user?.uid)!)"
        let followingPath = "Following/\((Global.sharedGlobal.user?.uid)!)/\((self.currentUser?.uid)!)"
        
        if (followButton.titleLabel?.text == "Follow") {
            let follower = ["name": Global.sharedGlobal.user?.getName(), "photo_url": Global.sharedGlobal.user?.profilePicLink, "uid": Global.sharedGlobal.user?.uid]
            let following = ["name":self.currentUser?.getName(), "photo_url": self.currentUser?.profilePicLink, "uid": self.currentUser?.uid]
            
            var followersCount:Int?
            var followingCount:Int?
            
            if (self.currentUser?.getFollowersCount() == nil) {
                followersCount = 1
                self.currentUser?.setFollowersCount(count: 1)
            } else {
                followersCount = (self.currentUser?.getFollowersCount())! + 1
                self.currentUser?.setFollowersCount(count: followersCount)
            }
            
            if (Global.sharedGlobal.user?.getFollowingCount() == nil) {
                followingCount = 1
                Global.sharedGlobal.user?.setFollowingCount(count: 1)
            } else {
                followingCount = (Global.sharedGlobal.user?.getFollowingCount())! + 1
                Global.sharedGlobal.user?.setFollowingCount(count: followingCount)
            }
            
            let childUpdates = [followersPath:follower, followingPath:following]
            FirebaseAPI.getDatabaseRef().updateChildValues(childUpdates)
            FirebaseAPI.getUsersRef().child("\((self.currentUser?.uid)!)").child("followers_count").setValue(followersCount)
            FirebaseAPI.getUsersRef().child("\((Global.sharedGlobal.user?.uid)!)").child("following_count").setValue(followingCount)
        } else {
            let childUpdates = [followersPath:NSNull(), followingPath:NSNull()]
            let followersCount = (self.currentUser?.getFollowersCount())! - 1
            let followingCount = (Global.sharedGlobal.user?.getFollowingCount())! - 1
            
            self.currentUser?.setFollowersCount(count: followersCount)
            Global.sharedGlobal.user?.setFollowingCount(count: followingCount)
            FirebaseAPI.getDatabaseRef().updateChildValues(childUpdates)
            FirebaseAPI.getUsersRef().child("\((self.currentUser?.uid)!)").child("followers_count").setValue(followersCount)
            FirebaseAPI.getUsersRef().child("\((Global.sharedGlobal.user?.uid)!)").child("following_count").setValue(followingCount)
        }
    }
    
    
    func logoutProfile() {
        let loginManager = LoginManager()
        //log off facebook
        loginManager.logOut()
        
        //log off firebase
        
        //segue into login screen on story board
        
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "messageFromProfile") {
            let chatVC = segue.destination as! ChatViewController
            var newChatGroup = [Dictionary<String, AnyObject>?]()
            
            let currentUser = ["uid": Global.sharedGlobal.user?.uid, "name": Global.sharedGlobal.user?.getName(), "photo_url": Global.sharedGlobal.user?.profilePicLink] as Dictionary<String, AnyObject>
            let userToMessage = ["uid": self.currentUser?.uid, "name": self.currentUser?.getName(), "photo_url": self.currentUser?.profilePicLink] as Dictionary<String, AnyObject>
            newChatGroup.append(currentUser)
            newChatGroup.append(userToMessage)
            
            chatVC.newChatGroup = newChatGroup
        }
    }
    
}
