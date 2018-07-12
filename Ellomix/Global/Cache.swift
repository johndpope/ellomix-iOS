//
//  Cache.swift
//  Ellomix
//
//  Created by Kevin Avila on 5/29/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

class Cache {
    
    let cache = NSCache<NSString, AnyObject>()
    
    func set(obj: AnyObject, key: NSString) {
        cache.setObject(obj, forKey: key)
    }
    
    func get(key: NSString) -> AnyObject? {
        return cache.object(forKey: key)
    }

}
