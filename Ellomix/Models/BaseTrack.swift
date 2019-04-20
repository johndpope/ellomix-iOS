//
//  Track.swift
//  Ellomix
//
//  Created by Kevin Avila on 10/17/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit

class BaseTrack {

    var id: String!
    var title: String!
    var artist: String!
    var thumbnailURL: String?
    var thumbnailImage: UIImage?
    var source: String!
    var order: Int?
    var sid: String?
    
    func toDictionary() -> Dictionary<String, AnyObject>  {
        var dict = Dictionary<String, AnyObject>()
        
        dict["id"] = id as AnyObject
        dict["title"] = title as AnyObject
        dict["artist"] = artist as AnyObject
        dict["source"] = source as AnyObject
        if (thumbnailURL != nil) { dict["thumbnail_url"] = thumbnailURL! as AnyObject }
        if (order != nil) { dict["order"] = order! as AnyObject }
        
        return dict
    }
    
    func downloadImage() {
        if let thumbnailURL = thumbnailURL, !thumbnailURL.isEmpty {
            if let cachedImage = Global.sharedGlobal.cache.get(key: thumbnailURL as NSString) as? UIImage {
                thumbnailImage = cachedImage
            } else {
                guard let url = URL(string: thumbnailURL) else { return }
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    guard
                        let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                        let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                        let data = data, error == nil,
                        let image = UIImage(data: data)
                        else { return }
                    DispatchQueue.main.async() { () -> Void in
                        Global.sharedGlobal.cache.set(obj: image, key: url.absoluteString as NSString)
                        self.thumbnailImage = image
                    }
                    }.resume()
            }
        }
    }

}
