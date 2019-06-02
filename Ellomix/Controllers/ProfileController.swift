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
    @IBOutlet weak var verticalLayoutConstraint: NSLayoutConstraint!
    
    private var FirebaseAPI: FirebaseApi!
    var currentUser: EllomixUser?
    var recentlyListenedSongs: [BaseTrack] = []
    var baseDelegate: ContainerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseAPI = FirebaseApi()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if (currentUser == nil) || (currentUser?.uid == Global.sharedGlobal.user?.uid) {
            // Viewing our profile
            currentUser = Global.sharedGlobal.user
            followButton.isHidden = true
            messageButton.isHidden = true
            editProfileButton.layer.cornerRadius = editProfileButton.frame.height / 2
            self.navigationItem.rightBarButtonItem = settingsButton
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
        clearSongs()
        retrieveRecentlyListened()
    }
    
    override func viewWillLayoutSubviews() {
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
    }
    
    func loadProfile() {
        navigationController?.navigationBar.topItem?.title = currentUser?.name
        profilePic.image = currentUser?.profilePicture.image
        
        var followersCount:Int?
        var followingCount:Int?
        
        if (currentUser?.followersCount == nil) {
            followersCount = 0
        } else {
            followersCount = currentUser?.followersCount
        }
        
        if (currentUser?.followingCount == nil) {
            followingCount = 0
        } else {
            followingCount = currentUser?.followingCount
        }

        followersCountButton.setTitle(String(describing: followersCount!), for: .normal)
        followingCountButton.setTitle(String(describing: followingCount!), for: .normal)
    }
    
    @IBAction func followUnfollowButtonClicked(_ sender: Any) {
        let followersPath = "Followers/\((self.currentUser?.uid)!)/\((Global.sharedGlobal.user?.uid)!)"
        let followingPath = "Following/\((Global.sharedGlobal.user?.uid)!)/\((self.currentUser?.uid)!)"
        
        if (followButton.titleLabel?.text == "Follow") {
            let follower = [
                "name": Global.sharedGlobal.user?.name,
                "photo_url": Global.sharedGlobal.user?.profilePicLink,
                "uid": Global.sharedGlobal.user?.uid,
                "device_token": Global.sharedGlobal.user?.deviceToken
            ]
            let following = [
                "name": self.currentUser?.name,
                "photo_url": self.currentUser?.profilePicLink,
                "uid": self.currentUser?.uid,
                "device_token": self.currentUser?.deviceToken
            ]
            
            var followersCount:Int?
            var followingCount:Int?
            
            if (self.currentUser?.followersCount == nil) {
                followersCount = 1
                self.currentUser?.followersCount = 1
            } else {
                followersCount = (self.currentUser?.followersCount)! + 1
                self.currentUser?.followersCount = followersCount
            }
            
            if (Global.sharedGlobal.user?.followingCount == nil) {
                followingCount = 1
                Global.sharedGlobal.user?.followingCount = 1
            } else {
                followingCount = (Global.sharedGlobal.user?.followingCount)! + 1
                Global.sharedGlobal.user?.followingCount = followingCount
            }
            
            let childUpdates = [followersPath:follower, followingPath:following]
            FirebaseAPI.getDatabaseRef().updateChildValues(childUpdates)
            FirebaseAPI.getUsersRef().child("\((self.currentUser?.uid)!)").child("followers_count").setValue(followersCount)
            FirebaseAPI.getUsersRef().child("\((Global.sharedGlobal.user?.uid)!)").child("following_count").setValue(followingCount)
        } else {
            let childUpdates = [followersPath:NSNull(), followingPath:NSNull()]
            let followersCount = (self.currentUser?.followersCount)! - 1
            let followingCount = (Global.sharedGlobal.user?.followingCount)! - 1
            
            self.currentUser?.followersCount = followersCount
            Global.sharedGlobal.user?.followingCount = followingCount
            FirebaseAPI.getDatabaseRef().updateChildValues(childUpdates)
            FirebaseAPI.getUsersRef().child("\((self.currentUser?.uid)!)").child("followers_count").setValue(followersCount)
            FirebaseAPI.getUsersRef().child("\((Global.sharedGlobal.user?.uid)!)").child("following_count").setValue(followingCount)
        }
    }
    
    @IBAction func followersButtonClicked(_ sender: AnyObject) {
        var followers: [Any] = []
        FirebaseAPI.getFollowersRef()
            .child((currentUser?.uid)!)
            .observe(.value, with: { (snapshot) in
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    followers.append(child.value!)
                }
                self.performSegue(withIdentifier: "toSeeFollowersFollowing", sender: followers)
            })
    }
    
    @IBAction func followingButtonClicked(_ sender: Any) {
        var following: [Any] = []
        FirebaseAPI.getFollowingRef()
            .child((currentUser?.uid)!)
            .observe(.value, with: { (snapshot) in
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    following.append(child.value!)
                }
                self.performSegue(withIdentifier: "toSeeFollowersFollowing", sender: following)
            })
    }
    
    
    //Number of views
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.recentlyListenedSongs.count
    }
    
    //Populate views
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recentlyListenedCell", for: indexPath) as! RecentlyListenedCollectionViewCell
        if (indexPath.item < (self.recentlyListenedSongs.count)) {
            let track = self.recentlyListenedSongs[indexPath.item]

            cell.artist.text = track.artist
            cell.thumbnail.downloadedFrom(link: track.thumbnailURL)
            cell.thumbnail.clipsToBounds = true
            cell.thumbnail.layer.cornerRadius = cell.thumbnail.frame.height / 2
            cell.thumbnail.contentMode = .scaleAspectFill
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let track = self.recentlyListenedSongs[indexPath.item]
        
        baseDelegate?.playTrack(track: track)
    }

    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "messageFromProfile") {
            let chatVC = segue.destination as! ChatViewController
            var newChatGroup = [EllomixUser]()
            
            let recipient = EllomixUser(uid: (Global.sharedGlobal.user?.uid)!)
            recipient.name = Global.sharedGlobal.user?.name
            recipient.profilePicLink = Global.sharedGlobal.user?.profilePicLink
            recipient.deviceToken = Global.sharedGlobal.user?.deviceToken
            
            let sender = EllomixUser(uid: (self.currentUser?.uid)!)
            sender.name = self.currentUser?.name
            sender.profilePicLink = self.currentUser?.profilePicLink
            sender.deviceToken = self.currentUser?.deviceToken

            newChatGroup.append(recipient)
            newChatGroup.append(sender)
            
            chatVC.newChatGroup = newChatGroup
        }
        if (segue.identifier == "toSeeFollowersFollowing") {
            let destinationVC = segue.destination as! SeeFollowersFollowingTableViewController
            if let users = sender as? [Any] {
                destinationVC.baseDelegate = baseDelegate
                destinationVC.users = users
            }
        }
    }
    
    func retrieveRecentlyListened() {
        self.FirebaseAPI.getUsersRef().child((currentUser?.uid)!).child("recently_listened")
            .queryOrderedByKey().queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { (snapshot) in
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    if let trackDict = child.value as? Dictionary<String, AnyObject> {
                        self.recentlyListenedSongs.append(trackDict.toBaseTrack())
                    }
                }
                self.recentlyListenedSongs.reverse()
                self.currentUser?.recentlyListenedSongs = self.recentlyListenedSongs.reversed()
                self.collectionView.reloadData()
                self.verticalLayoutConstraint.constant = self.collectionView.collectionViewLayout.collectionViewContentSize.height;
        })
    }
    
    func clearSongs() {
        self.recentlyListenedSongs = []
    }
}
