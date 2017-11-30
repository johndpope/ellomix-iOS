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
    private let CHATS = "Chats"
    private let USERS = "Users"
    private let CHAT_USER = "ChatUser"
    
    private var storageRef: StorageReference = Storage.storage().reference()

    func getDatabaseRef() -> DatabaseReference {
        return ref;
    }
    
    func getChatsRef() -> DatabaseReference {
        return ref.child(CHATS)
    }

    func getChatUserRef() -> DatabaseReference {
        return ref.child(CHAT_USER)
    }

    func getUsersRef() -> DatabaseReference {
        return ref.child(USERS)
    }
    
    func getUserStorageRef(uid: String) -> StorageReference {
        return storageRef.child(uid)
    }
    
    func updateUserProfilePicture(user: EllomixUser, image: UIImage) {
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
            }
        })
    }

    func updateUser(user: EllomixUser) {
        let newUserRef = ref.child(USERS).child(user.uid)
        newUserRef.setValue(user.toDictionary())
    }
}
