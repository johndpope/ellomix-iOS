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
    var caption: String?
    
    func toDictionary() -> Dictionary<String, AnyObject>  {
        var dict = Dictionary<String, AnyObject>()
        
        dict["track"] = track.toDictionary() as AnyObject
        dict["likes"] = likes as AnyObject
        dict["comments"] = comments as AnyObject
        dict["timestamp"] = timestamp as AnyObject
        if (caption != nil) { dict["caption"] = caption! as AnyObject }
        
        return dict
    }
}
