//
//  FirebaseApi.swift
//  Ellomix
//
//  Created by Akshay Vyas on 2/17/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import Foundation
import FirebaseDatabase


class FirebaseApi {
    
    private var ref: DatabaseReference = Database.database().reference()
    private let CHATS = "Chats"
    private let USERS = "Users"
    private let CHAT_USER = "ChatUser"
    
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

    func updateUser(user: EllomixUser) {
        let newUserRef = ref.child(USERS).child(user.uid)
        newUserRef.setValue(user.toDictionary())
    }
}
