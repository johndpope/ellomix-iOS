//
//  Extensions.swift
//  Ellomix
//
//  Created by Kevin Avila on 2/10/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UILabel {
    func circular() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
}

extension UIButton {
    func circular() {
        self.layer.cornerRadius = self.frame.height / 2
    }
}

extension UITextField {
    func underlined() {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}

extension UIImage {
    static func downloadImage(url: String?, completion: @escaping ((UIImage) -> ())) {
        if let url = url, !url.isEmpty {
            if let cachedImage = Global.sharedGlobal.cache.get(key: url as NSString) as? UIImage {
                completion(cachedImage)
            } else {
                guard let url = URL(string: url) else { return }
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    guard
                        let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                        let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                        let data = data, error == nil,
                        let image = UIImage(data: data)
                        else { return }
                    DispatchQueue.main.async() { () -> Void in
                        Global.sharedGlobal.cache.set(obj: image, key: url.absoluteString as NSString)
                        completion(image)
                    }
                    }.resume()
            }
        } else {
            completion(#imageLiteral(resourceName: "ellomix_logo_bw"))
        }
    }
}

extension UIImageView {
    //TODO: Refactor to use UIImage downloadImage() instead
    func downloadedFrom(url: URL) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                Global.sharedGlobal.cache.set(obj: image, key: url.absoluteString as NSString)
                self.image = image
            }
            }.resume()
    }
    
    func downloadedFrom(link: String?) {
        if let link = link, !link.isEmpty {
            if let cachedImage = Global.sharedGlobal.cache.get(key: link as NSString) as? UIImage {
                self.image = cachedImage
            } else {
                guard let url = URL(string: link) else { return }
                downloadedFrom(url: url)
            }
        } else {
            self.image = #imageLiteral(resourceName: "ellomix_logo_bw")
        }
    }
    
    func circular() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
}

extension Array {
    // Fisher–Yates shuffle
    func shuffle() -> [AnyObject] {
        var arr = self as [AnyObject]
        var temporaryValue: AnyObject!
        var randomIndex = 0
        var currentIndex = arr.count
        
        while (currentIndex != 0) {
            randomIndex = Int(floor((Float(arc4random()) / Float(UINT32_MAX)) * Float(currentIndex)))
            currentIndex-=1
            
            temporaryValue = arr[currentIndex] as AnyObject
            arr[currentIndex] = arr[randomIndex] as AnyObject
            arr[randomIndex] = temporaryValue
        }
        
        return arr
    }
}

extension Dictionary {
    func groupNameFromUsers() -> String {
        var names = [String]()

        for val in self.values {
            let obj = val as AnyObject
            if let name = obj["name"] as? String, name != Global.sharedGlobal.user?.getName() {
                names.append(name)
            }
        }
        
        return names.joined(separator: ", ")
    }
    
    func usersArray() -> [Dictionary<String, AnyObject>] {
        var arr = [Dictionary<String, AnyObject>]()
        for (key, val) in self {
            if var dict = val as? Dictionary<String, AnyObject> {
                dict["uid"] = key as AnyObject
                arr.append(dict)
            }
        }
        
        return arr
    }
    
    func toEllomixUser() -> EllomixUser? {
        let userDict = self as! Dictionary<String, AnyObject>
        if let uid = userDict["uid"] as? String {
            let user = EllomixUser(uid: uid)
            if let name = userDict["name"] as? String { user.setName(name: name) }
            if let photoUrl = userDict["photo_url"] as? String { user.setProfilePicLink(link: photoUrl) }
            //TODO: Set the rest of the properties
            
            return user
        }
        
        return nil
    }
    
    func toGroup() -> Group? {
        let groupDict = self as! Dictionary<String, AnyObject>
        if let gid = groupDict["gid"] as? String {
            let group = Group()
            group.gid = gid
            if let name = groupDict["name"] as? String { group.name = name }
            if let users = groupDict["users"] as? Dictionary<String, AnyObject> { group.users = users }
            if let lastMessageDictionary = groupDict["last_message"] as? Dictionary<String, AnyObject> {
                let lastMessage = Message()
                lastMessage.content = lastMessageDictionary["content"] as? String
                lastMessage.timestamp = lastMessageDictionary["timestamp"] as? Int
                group.lastMessage = lastMessage
            }
            
            return group
        }
        
        return nil
    }
    
    func toMessage() -> Message? {
        let messageDict = self as! Dictionary<String, AnyObject>
        
        let message = Message()
        if let uid = messageDict["uid"] as? String { message.uid = uid }
        if let type = messageDict["type"] as? String { message.type = type }
        if let content = messageDict["content"] as? String { message.content = content }
        if let trackDict = messageDict["track"] as? Dictionary<String, AnyObject> { message.track = trackDict.toBaseTrack() }
        if let timestamp = messageDict["timestamp"] as? Int { message.timestamp = timestamp }
        
        return message
    }
    
    func toBaseTrack() -> BaseTrack {
        let trackDict = self as! Dictionary<String, AnyObject>
        let track = BaseTrack()
        
        if let id = trackDict["id"] as? String { track.id = id }
        if let title = trackDict["title"] as? String { track.title = title }
        if let arist = trackDict["artist"] as? String { track.artist = arist }
        if let source = trackDict["source"] as? String { track.source = source }
        if let thumbnailURL = trackDict["thumbnail_url"] as? String { track.thumbnailURL = thumbnailURL }
        if let order = trackDict["order"] as? Int { track.order = order }

        return track
    }

    func toPost() -> Post? {
        let postDict = self as! Dictionary<String, AnyObject>

        let post = Post()
        if let trackDict = postDict["track"] as? Dictionary<String, AnyObject> { post.track = trackDict.toBaseTrack() }
        if let likes = postDict["likes"] as? Int { post.likes = likes }
        if let comments = postDict["comments"] as? Int { post.comments = comments }
        if let timestamp = postDict["timestamp"] as? Int { post.timestamp = timestamp }
        if let uid = postDict["uid"] as? String { post.uid = uid }
        if let name = postDict["name"] as? String { post.name = name }
        if let photoUrl = postDict["photoUrl"] as? String { post.photoUrl = photoUrl }
        if let caption = postDict["caption"] as? String { post.caption = caption }

        return post
    }

}

extension Date {
    func timeAgoDisplay() -> String {
        let calendar = Calendar.current
        let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        if minuteAgo < self {
            let diff = Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
            return "\(diff)s"
        } else if hourAgo < self {
            let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
            return "\(diff)m"
        } else if dayAgo < self {
            let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
            return "\(diff)h"
        } else if weekAgo < self {
            let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
            return "\(diff)d"
        }
        let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
        return "\(diff)w"
    }
}

extension YouTubePlayerView {
    func playPause(button: UIButton) {
        if (Global.sharedGlobal.youtubePlayer?.playerState == YouTubePlayerState.Playing) {
            button.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            Global.sharedGlobal.youtubePlayer?.pause()
        } else {
            button.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            Global.sharedGlobal.youtubePlayer?.play()
        }
    }
    
    func setButton(button: UIButton) {
        if (Global.sharedGlobal.youtubePlayer?.playerState == YouTubePlayerState.Playing) {
            button.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        } else {
            button.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        }
    }
}

//Mark: Color Palette

extension UIColor {
    class func ellomixBlue() -> UIColor {
        return UIColor(red:0.40, green:0.56, blue:0.94, alpha:1.0)
    }
    
    class func ellomixLightGray() -> UIColor {
        return UIColor(red:0.90, green:0.90, blue:0.90, alpha:1.0)
    }
}
