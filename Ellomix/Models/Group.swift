//
//  Group.swift
//  Ellomix
//
//  Created by Kevin Avila on 3/30/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import Foundation

internal class Group {
    
    var gid: String?
    var name: String?
    var lastMessage: Message?
    var users: [EllomixUser]?
    
    func containsUser(uid: String) -> Bool {
        var containsUser = false
        
        if (users != nil) {
            for user in users! {
                if (user.uid == uid) {
                    containsUser = true
                }
            }
        }
        
        return containsUser
    }
    
    func removeUser(uid: String) {
        var userIndex = -1

        if (users != nil) {
            for i in 0..<users!.count {
                let user = users![i]
                if (user.uid == uid) {
                    userIndex = i
                }
            }
        }

        if (userIndex > -1) {
            users!.remove(at: userIndex)
        }
    }

}
