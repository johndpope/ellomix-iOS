//
//  Message.swift
//  Ellomix
//
//  Created by Kevin Avila on 3/20/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import Foundation

internal class Message {
    
    var uid: String?
    var type: String!
    var content: String?
    var timestamp: Int?
    var isRead: Bool?
    var image: UIImage?
    var track: BaseTrack?
    
    func toDictionary() -> Dictionary<String, AnyObject>  {
        var dict = Dictionary<String, AnyObject>()
    
        if (uid != nil) { dict["uid"] = uid! as AnyObject }
        if (content != nil) { dict["content"] = content! as AnyObject }
        if (timestamp != nil) { dict["timestamp"] = timestamp! as AnyObject }
        if (track != nil) { dict["track"] = track!.toDictionary() as AnyObject }
        dict["type"] = type as AnyObject

        return dict
    }
    
}
