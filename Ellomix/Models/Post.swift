//
//  Post.swift
//  Ellomix
//
//  Created by Kevin Avila on 2/18/19.
//  Copyright © 2019 Ellomix. All rights reserved.
//

import Foundation

class Post {
    
    var track: BaseTrack!
    var likes: Int!
    var comments: Int!
    var timestamp: Int!
    var uid: String!
    var name: String!
    var caption: String?
    var photoUrl: String?
    
    func toDictionary() -> Dictionary<String, AnyObject>  {
        var dict = Dictionary<String, AnyObject>()
        
        dict["track"] = track.toDictionary() as AnyObject
        dict["likes"] = likes as AnyObject
        dict["comments"] = comments as AnyObject
        dict["timestamp"] = timestamp as AnyObject
        dict["uid"] = uid as AnyObject
        dict["name"] = name as AnyObject
        if (caption != nil) { dict["caption"] = caption! as AnyObject }
        if (photoUrl != nil) { dict["photoUrl"] = photoUrl! as AnyObject }
        
        return dict
    }
}
