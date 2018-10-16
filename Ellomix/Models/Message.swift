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
    
    func toDictionary() -> Dictionary<String, AnyObject>  {
        return [
            "uid": uid! as AnyObject,
            "content": content! as AnyObject,
            "type": type as AnyObject,
            "timestamp": timestamp! as AnyObject
        ]
    }
    
}
