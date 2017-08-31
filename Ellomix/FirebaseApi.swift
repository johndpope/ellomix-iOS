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
    
    private var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    private let CHATS = "Chats"
    private let USERS = "Users"
    
    func getDatabaseRef() -> FIRDatabaseReference {
        return ref;
    }
    
    func getChatsRef() -> FIRDatabaseReference {
        return ref.child(CHATS)
    }
    
    func getUsersRef() -> FIRDatabaseReference {
        return ref.child(USERS)
    }
    
    func createUser(user: User) {
        let newUserRef = ref.child(USERS).child(user.uid)
        newUserRef.setValue(user.toDictionary())
    }
}
