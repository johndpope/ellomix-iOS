//
//  User.swift
//  Ellomix
//
//  Created by Kevin Avila on 8/27/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import Foundation
import UIKit

class EllomixUser {
    
    var uid: String!
    var name: String!
    var profilePicLink: String?
    var profilePicture: UIImageView = UIImageView()
    var website: String?
    var bio: String?
    var email: String?
    var gender: String?
    var birthday: String?
    var password: String?
    var deviceToken: String?
    var followingCount: Int?
    var followersCount: Int?
    var groups: [String: Bool] = [:]
    var recentlyListenedSongs: [BaseTrack] = []
    
    init(uid: String) {
        self.uid = uid
    }
    
    func toDictionary() -> Dictionary<String, AnyObject> {
        var dict = Dictionary<String, AnyObject>()

        dict["uid"] = uid as AnyObject
        dict["name"] = name as AnyObject
        if (deviceToken != nil) { dict["device_token"] = deviceToken! as AnyObject }
        if (profilePicLink != nil) {dict["photo_url"] = profilePicLink! as AnyObject }
        if (password != nil) { dict["password"] = password! as AnyObject }
        if (!groups.isEmpty) { dict["groups"] = groups as AnyObject }
        if (website != nil) { dict["website"] = website! as AnyObject }
        if (bio != nil) { dict["bio"] = bio! as AnyObject }
        if (email != nil) { dict["email"] = email! as AnyObject }
        if (gender != nil) { dict["gender"] = gender! as AnyObject }
        if (birthday != nil) { dict["birthday"] = birthday! as AnyObject }
        if (followingCount != nil) { dict["following_count"] = followingCount! as AnyObject }
        if (followersCount != nil) { dict["followers_count"] = followersCount! as AnyObject }

        if (!recentlyListenedSongs.isEmpty) {
            var recentlyListenedSongsDict = Dictionary<String, AnyObject>()

            for track in recentlyListenedSongs {
                if let sid = track.sid {
                    recentlyListenedSongsDict[sid] = track.toDictionary() as AnyObject
                }
            }

            dict["recently_listened"] = recentlyListenedSongsDict as AnyObject
        }

        return dict
    }
}
