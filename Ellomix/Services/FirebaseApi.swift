//
//  FirebaseApi.swift
//  Ellomix
//
//  Created by Akshay Vyas on 2/17/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseMessaging
import UIKit

class FirebaseApi {
    
    private var ref: DatabaseReference = Database.database().reference()
    private let USERS = "Users"
    private let MESSAGES = "Messages"
    private let GROUPS = "Groups"
    private let GROUP_PLAYLISTS = "GroupPlaylists"
    private let FOLLOWING = "Following"
    private let FOLLOWERS = "Followers"
    private let POSTS = "Posts"
    private let TIMELINE = "Timeline"
    
    private var storageRef: StorageReference = Storage.storage().reference()

    func getDatabaseRef() -> DatabaseReference {
        return ref;
    }
    
    func getMessagesRef() -> DatabaseReference {
        return ref.child(MESSAGES)
    }

    func getGroupsRef() -> DatabaseReference {
        return ref.child(GROUPS)
    }
    
    func getGroupPlaylistsRef() -> DatabaseReference {
        return ref.child(GROUP_PLAYLISTS)
    }

    func getUsersRef() -> DatabaseReference {
        return ref.child(USERS)
    }
    
    func getFollowingRef() -> DatabaseReference {
        return ref.child(FOLLOWING)
    }
    
    func getFollowersRef() -> DatabaseReference {
        return ref.child(FOLLOWERS)
    }
    
    func getPostsRef() -> DatabaseReference {
        return ref.child(POSTS)
    }
    
    func getTimelineRef() -> DatabaseReference {
        return ref.child(TIMELINE)
    }
    
    func getUserStorageRef(uid: String) -> StorageReference {
        return storageRef.child(uid)
    }
    
    func updateUserProfilePicture(user: EllomixUser, image: UIImage, completion: @escaping () -> Void) {
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        let imageData = UIImageJPEGRepresentation(image, 0.8)
        let imageStorageRef = storageRef.child(user.uid+"/profile_picture/image.jpg")

        imageStorageRef.putData(imageData!, metadata: uploadMetadata, completion: { (metadata, error) in
            if (error != nil) {
                print("Error uploading image: \(String(describing: error?.localizedDescription))")
            } else {
                print("Successfully uploaded image")
                let userPhotoURLRef = self.ref.child(self.USERS).child(user.uid).child("photo_url")
                user.profilePicLink = (metadata?.downloadURL()?.absoluteString)!
                userPhotoURLRef.setValue((metadata?.downloadURL()?.absoluteString)!)
                completion()
            }
        })
    }
    
    func getUser(uid: String, completed: @escaping (EllomixUser) -> ()) {
        let userRef = ref.child(USERS).child(uid)
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if var userDict = snapshot.value as? Dictionary<String, AnyObject> {
                userDict["uid"] = uid as AnyObject
                if let user = userDict.toEllomixUser() {
                    completed(user)
                }
            }
        })
    }

    func updateUser(user: EllomixUser) {
        let newUserRef = ref.child(USERS).child(user.uid)
        newUserRef.setValue(user.toDictionary())
    }
    
    func updateGroupChat(group: Group, user: EllomixUser) {
        let groupChatRef = ref.child(GROUPS).child(group.gid!)
        let userRef = ref.child(USERS).child(user.uid)

        if let name = group.name {
            groupChatRef.child("name").setValue(name)
        }
        if let users = group.users {
            groupChatRef.child("users").updateChildValues(users.userDictionaryByKey(key: "uid"))
        }

        // Update user's notification setting for this group
        if let gid = group.gid {
            userRef.child("groups").child(gid).setValue(user.groups[gid])
        }
    }
    
    func leaveGroupChat(group: Group, uid: String) {
        let groupChatRef = ref.child(GROUPS).child(group.gid!)
        let userRef = ref.child(USERS).child(uid)
        
        groupChatRef.child("users").child(uid).removeValue()
        userRef.child("groups").child(group.gid!).removeValue()
    }
    
    func sendMessageToUsers(sender: EllomixUser, users: [EllomixUser], message: Message, completed: @escaping (String) -> ()) {
        var groupToCheck = users
        groupToCheck.append(sender)
        checkForExistingGroup(uid: sender.uid, groupToCheck: groupToCheck) { (existingGroup) -> () in
            if (existingGroup != nil) {
                self.sendMessageToGroupChat(gid: existingGroup!.gid!, message: message)
                completed(existingGroup!.gid!)
            } else {
                self.sendMessageToNewGroupChat(users: groupToCheck, message: message) { (gid) -> () in
                    completed(gid)
                }
            }
        }
    }
    
    func sendMessageToNewGroupChat(users: [EllomixUser], message: Message, completed: @escaping (String) -> ()) {
        let groupChatRef = ref.child(GROUPS)
        let usersRef = ref.child(USERS)
        
        groupChatRef.childByAutoId().observeSingleEvent(of: .value, with: { (snapshot) in
            let gid = snapshot.key
            var usersData = Dictionary<String, AnyObject>()
            
            for user in users {
                usersData[user.uid] = [
                    "name": user.name,
                    "photo_url": user.profilePicLink,
                    "device_token": user.deviceToken
                ] as AnyObject
                usersRef.child(user.uid).child("groups").child(gid).setValue(true)
            }
            
            groupChatRef.child(gid).child("users").updateChildValues(usersData)
            self.sendMessageToGroupChat(gid: gid, message: message)
            completed(gid)
        })
    }
    
    func sendMessageToGroupChat(gid: String, message: Message) {
        let messagesRef = ref.child(MESSAGES).child(gid)
        let lastMessageRef = ref.child(GROUPS).child(gid).child("last_message")
        
        messagesRef.childByAutoId().updateChildValues(message.toDictionary())
        lastMessageRef.updateChildValues(message.toDictionary())
    }
    
    func checkForExistingGroup(uid: String, groupToCheck: [EllomixUser], completed: @escaping (Group?) -> ()) {
        let usersRef = ref.child(USERS).child(uid)
        let groupsRef = ref.child(GROUPS)
        
        var userIds = [String]()
        groupToCheck.forEach { userIds.append($0.uid) }
        usersRef.child("groups").observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            var counter = 0
            var foundGroup = false
            let groupCount = snapshot.childrenCount
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let gid = child.key
                
                groupsRef.child(gid).observeSingleEvent(of: .value, with: { (snapshot) in
                    if (!foundGroup) {
                        if var groupDict = snapshot.value as? Dictionary<String, AnyObject> {
                            groupDict["gid"] = snapshot.key as AnyObject
                            if let group = groupDict.toGroup() {
                                if let users = group.users  {
                                    var currentUserIds = [String]()
                                    users.forEach { currentUserIds.append($0.uid) }
                                    
                                    if (Set(currentUserIds) == Set(userIds)) {
                                        foundGroup = true
                                        completed(group)
                                    } else if (counter == (groupCount - 1)) {
                                        completed(nil)
                                    }
                                    counter+=1
                                }
                            }
                        }
                    }
                })
            }
        })
    }
    
    func addToGroupPlaylist(group: Group, data: [BaseTrack]) {
        let groupPlaylistRef = ref.child(GROUP_PLAYLISTS).child(group.gid!)
        var values = Dictionary<String, AnyObject>()
        
        for i in 0..<data.count {
            let key = groupPlaylistRef.childByAutoId().key
            values[key] = data[i].toDictionary() as AnyObject
        }
        groupPlaylistRef.updateChildValues(values)
    }
    
    func orderGroupPlaylist(group: Group, data: [BaseTrack]) {
        let groupPlaylistRef = ref.child(GROUP_PLAYLISTS).child(group.gid!)
        
        for track in data {
            if let sid = track.sid {
                groupPlaylistRef.child(sid).child("order").setValue(track.order)
            }
        }
    }
    
    func removeFromGroupPlaylist(group: Group, key: String, data: [BaseTrack]) {
        let groupPlaylistRef = ref.child(GROUP_PLAYLISTS).child(group.gid!)
        
        groupPlaylistRef.child(key).removeValue()
        orderGroupPlaylist(group: group, data: data)
    }
    
    func sharePost(post: Post) {
        let postsRef = ref.child(POSTS).child(post.uid).childByAutoId()
        let followersRef = ref.child(FOLLOWERS).child(post.uid)
        let timelineRef = ref.child(TIMELINE)
        let pid = postsRef.key
        
        postsRef.updateChildValues(post.toDictionary())
        
        // Write the post to the current user's timeline
        timelineRef.child(post.uid).child(pid).updateChildValues(post.toDictionary())
        
        // Write the post to each follower's timeline
        followersRef.observe(.childAdded, with: { (snapshot) in
            let followerUid = snapshot.key
            
            timelineRef.child(followerUid).child(pid).updateChildValues(post.toDictionary())
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getUserTimeline(uid: String, completion: (([Post]) -> ())? = nil) {
        let timelineRef = ref.child(TIMELINE).child(uid)
        var posts = [Post]()

        timelineRef.queryOrdered(byChild: "order").observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if let postDict = child.value as? Dictionary<String, AnyObject> {
                    if let post = postDict.toPost() {
                        posts.append(post)
                    }
                }
            }

            completion?(posts)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func updateUserDeviceToken(uid: String, token: String) {
        let userRef = ref.child(USERS).child(uid)
        
        userRef.child("device_token").setValue(token)
    }
    
    func updateRecentlyListened(track: BaseTrack) {
        let recentlyListenedValues = track.toDictionary()
        getUsersRef().child((Global.sharedGlobal.user?.uid)!).child("recently_listened").childByAutoId().updateChildValues(recentlyListenedValues)
    }
}
