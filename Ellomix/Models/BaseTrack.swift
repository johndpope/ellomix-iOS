//
//  Track.swift
//  Ellomix
//
//  Created by Kevin Avila on 10/17/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

class BaseTrack {

    var id: String!
    var title: String!
    var artist: String!
    var thumbnailURL: String?
    var thumbnailImage: String?
    var source: String!
    
    func toDictionary() -> Dictionary<String, AnyObject>  {
        var dict = Dictionary<String, AnyObject>()
        
        dict["id"] = id as AnyObject
        dict["title"] = title as AnyObject
        dict["artist"] = artist as AnyObject
        dict["source"] = source as AnyObject
        if (thumbnailURL != nil) { dict["thumbnail_url"] = thumbnailURL! as AnyObject }
        
        return dict
    }

}
