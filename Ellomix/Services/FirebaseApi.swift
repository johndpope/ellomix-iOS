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
                user.setProfilePicLink(link: (metadata?.downloadURL()?.absoluteString)!)
                userPhotoURLRef.setValue((metadata?.downloadURL()?.absoluteString)!)
                completion()
            }
        })
    }

    func updateUser(user: EllomixUser) {
        let newUserRef = ref.child(USERS).child(user.uid)
        newUserRef.setValue(user.toDictionary())
    }
    
    func updateGroupChat(group: Group) {
        let groupChatRef = ref.child(GROUPS).child(group.gid!)
        if let name = group.name {
            groupChatRef.child("name").setValue(name)
        }
        if let users = group.users {
            groupChatRef.child("users").updateChildValues(users)
        }
    }
    
    func leaveGroupChat(group: Group, uid: String) {
        let groupChatRef = ref.child(GROUPS).child(group.gid!)
        let userRef = ref.child(USERS).child(uid)
        
        groupChatRef.child("users").child(uid).removeValue()
        userRef.child("groups").child(group.gid!).removeValue()
    }
    
    func sendMessageToUsers(sender: EllomixUser, users: [EllomixUser], message: Message) {
        var groupToCheck = users
        groupToCheck.append(sender)
        checkForExistingGroup(uid: sender.uid, groupToCheck: groupToCheck) { (existingGroupGid) -> () in
            if (existingGroupGid != nil) {
                self.sendMessageToGroupChat(gid: existingGroupGid!, message: message)
            } else {
                self.sendMessageToNewGroupChat(users: groupToCheck, message: message)
            }
        }
    }
    
    func sendMessageToNewGroupChat(users: [EllomixUser], message: Message) {
        let groupChatRef = ref.child(GROUPS)
        let usersRef = ref.child(USERS)
        
        groupChatRef.childByAutoId().observeSingleEvent(of: .value, with: { (snapshot) in
            let gid = snapshot.key
            var usersData = Dictionary<String, AnyObject>()
            
            for user in users {
                usersData[user.uid] = [
                    "name": user.name,
                    "photo_url": user.profilePicLink,
                    "notifications": true
                ] as AnyObject
                usersRef.child(user.uid).child("groups").child(gid).setValue(true)
            }
            
            groupChatRef.child(gid).child("users").updateChildValues(usersData)
            self.sendMessageToGroupChat(gid: gid, message: message)
        })
    }
    
    func sendMessageToGroupChat(gid: String, message: Message) {
        let messagesRef = ref.child(MESSAGES).child(gid)
        let lastMessageRef = ref.child(GROUPS).child(gid).child("last_message")
        
        messagesRef.childByAutoId().updateChildValues(message.toDictionary())
        lastMessageRef.updateChildValues(message.toDictionary())
    }
    
    func checkForExistingGroup(uid: String, groupToCheck: [EllomixUser], completed: @escaping (String?) -> ()) {
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
                        if let dictionary = snapshot.value as? Dictionary<String, AnyObject> {
                            if let users = dictionary["users"] as? Dictionary<String, AnyObject> {
                                let currentGroup = Array(users.keys)
                                
                                if (Set(currentGroup) == Set(userIds)) {
                                    foundGroup = true
                                    completed(gid)
                                } else if (counter == (groupCount - 1)) {
                                    completed(nil)
                                }
                                counter+=1
                            }
                        }
                    }
                })
            }
        })
    }
    
    func addToGroupPlaylist(group: Group, data: [Dictionary<String, AnyObject>]) {
        let groupPlaylistRef = ref.child(GROUP_PLAYLISTS).child(group.gid!)
        var values = Dictionary<String, AnyObject>()
        
        for i in 0..<data.count {
            let key = groupPlaylistRef.childByAutoId().key
            values[key] = data[i] as AnyObject
        }
        groupPlaylistRef.updateChildValues(values)
    }
    
    func orderGroupPlaylist(group: Group, data: [Dictionary<String, AnyObject>]) {
        let groupPlaylistRef = ref.child(GROUP_PLAYLISTS).child(group.gid!)
        
        for track in data {
            let key = track["key"] as! String
            let order = track["order"] as! Int
            groupPlaylistRef.child(key).child("order").setValue(order)
        }
    }
    
    func removeFromGroupPlaylist(group: Group, key: String, data: [Dictionary<String, AnyObject>]) {
        let groupPlaylistRef = ref.child(GROUP_PLAYLISTS).child(group.gid!)
        
        groupPlaylistRef.child(key).removeValue()
        orderGroupPlaylist(group: group, data: data)
    }
    
    func updateUserDeviceToken(uid: String, token: String) {
        let userRef = ref.child(USERS).child(uid)
        
        userRef.child("device_token").setValue(token)
    }
}
