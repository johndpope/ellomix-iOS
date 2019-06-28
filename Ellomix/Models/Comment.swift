//
//  Comment.swift
//  Ellomix
//
//  Created by Kevin Avila on 6/28/19.
//  Copyright © 2019 Ellomix. All rights reserved.
//

import Foundation

class Comment {

    var name: String!
    var comment: String!
    var photoUrl: String?

    func toDictionary() -> Dictionary<String, AnyObject>  {
        var dict = Dictionary<String, AnyObject>()

        dict["name"] = name as AnyObject
        dict["comment"] = comment as AnyObject
        if (photoUrl != nil) { dict["photo_url"] = photoUrl! as AnyObject }

        return dict
    }
}
