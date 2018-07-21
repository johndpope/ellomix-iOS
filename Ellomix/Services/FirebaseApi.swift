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
}
