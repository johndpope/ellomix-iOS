//
//  Post.swift
//  Ellomix
//
//  Created by Kevin Avila on 2/18/19.
//  Copyright © 2019 Ellomix. All rights reserved.
//

import Foundation

class Post {
    
    var pid: String!
    var track: BaseTrack!
    var comments: Int!
    var timestamp: Int!
    var uid: String!
    var name: String!
    var caption: String?
    var photoUrl: String?
    var likes: [String: Bool] = [:]
    
    func toDictionary() -> Dictionary<String, AnyObject>  {
        var dict = Dictionary<String, AnyObject>()

        dict["track"] = track.toDictionary() as AnyObject
        dict["comments"] = comments as AnyObject
        dict["timestamp"] = timestamp as AnyObject
        dict["order"] = -timestamp as AnyObject // Used for ordering posts by most recent date when retrieving from Firebase
        dict["uid"] = uid as AnyObject
        dict["name"] = name as AnyObject
        if (caption != nil) { dict["caption"] = caption! as AnyObject }
        if (photoUrl != nil) { dict["photo_url"] = photoUrl! as AnyObject }
        if (!likes.isEmpty) { dict["likes"] = likes as AnyObject }
        
        return dict
    }
}
