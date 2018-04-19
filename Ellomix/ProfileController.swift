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
import Soundcloud

class ProfileController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var followersCountButton: UIButton!
    @IBOutlet weak var followingCountButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var settingsButton: UIBarButtonItem!
    
    
    private var FirebaseAPI: FirebaseApi!
    var currentUser:EllomixUser?
    var recentlyListenedSongs:[String:[AnyObject]] = ["Spotify":[], "Soundcloud":[], "YouTube":[]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseAPI = FirebaseApi()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if (currentUser == nil) {
            // Viewing our profile
            currentUser = Global.sharedGlobal.user
            followButton.isHidden = true
            messageButton.isHidden = true
            editProfileButton.layer.cornerRadius = editProfileButton.frame.height / 2
            self.navigationItem.rightBarButtonItem = settingsButton
            retrieveRecentlyListened(uid: (currentUser?.uid)!)
        } else {
            // Viewing another user's profile
            editProfileButton.isHidden = true
            followButton.layer.cornerRadius = followButton.frame.height / 2
            messageButton.layer.cornerRadius = messageButton.frame.height / 2
            self.navigationItem.rightBarButtonItem = nil
            
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
    
    //Number of views
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recentlyListenedSongs.count
    }
    
    //Populate views
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recentlyListenedCell", for: indexPath) as! RecentlyListenedCollectionViewCell
        if (indexPath.item < (recentlyListenedSongs["Soundcloud"]?.count)!) {
            let scTrack = recentlyListenedSongs["Soundcloud"]?[indexPath.item] as? SoundcloudTrack
            cell.artist.text = scTrack?.artist
            cell.thumbnail.image = scTrack?.thumbnailImage
            
            cell.thumbnail.clipsToBounds = true
            cell.thumbnail.layer.cornerRadius = cell.thumbnail.frame.height / 2
            cell.thumbnail.contentMode = .scaleAspectFill
        }
        return cell
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
    
    func retrieveRecentlyListened(uid: String) {
        self.FirebaseAPI.getUsersRef().child(uid).child("recently_listened").observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionaryRecentlyListened = snapshot.value as? Dictionary<String, AnyObject> {
                print(dictionaryRecentlyListened)
                let idList = Array(dictionaryRecentlyListened.keys)
                for id in idList {
                    if (dictionaryRecentlyListened[id]!["type"] as! String) == "soundcloud" {
                        self.loadSoundcloudTrack(id: Int(id)!)
                    }
                }
            }
        })
    }
    
    func loadSoundcloudTrack(id: Int) {
        Track.track(identifier: id) { response in
            print("--------------REQUESTING FROM SOUNDCLOUD---------------")
            //print("Soundcloud response: \(response.response.result)")
            if let track = response.response.result {
                let scTrack = SoundcloudTrack()
                    
                scTrack.title = track.title
                scTrack.artist = track.createdBy.username
                scTrack.url = track.streamURL
                scTrack.id = String(track.identifier)
                if (track.artworkImageURL.highURL != nil) {
                    scTrack.thumbnailURL = track.artworkImageURL.highURL
                } else if (track.createdBy.avatarURL.highURL != nil) {
                    scTrack.thumbnailURL = track.createdBy.avatarURL.highURL
                } else {
                    scTrack.thumbnailImage = UIImage()
                }
                    
                if (scTrack.thumbnailURL != nil) {
                    DispatchQueue.global().async {
                        let data = try? Data(contentsOf: scTrack.thumbnailURL!)
                        DispatchQueue.main.async {
                            scTrack.thumbnailImage = UIImage(data: data!)
                            self.collectionView.reloadData()
                        }
                    }
                }
                self.recentlyListenedSongs["Soundcloud"]?.append(scTrack)
                print(self.recentlyListenedSongs)
                }
            self.collectionView.reloadData()
            }
    }
}
