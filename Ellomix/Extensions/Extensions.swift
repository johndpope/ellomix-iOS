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
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UILabel {
    func circular() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
}

extension UITextField {
    func underlined(){
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}

extension UIImageView {
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
    
    func downloadedFrom(link: String) {
        if let cachedImage = Global.sharedGlobal.cache.get(key: link as NSString) as? UIImage {
            self.image = cachedImage
        } else {
            guard let url = URL(string: link) else { return }
            downloadedFrom(url: url)
        }
    }
    
    func circular() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
}

extension Array {
    func groupNameFromUsers() -> String {
        var names = [String]()
        
        for i in 0..<self.count {
            if let user = self[i] as? Dictionary<String, AnyObject> {
                if let name = user["name"] as? String, name != Global.sharedGlobal.user?.getName() {
                    names.append(name)
                }
            }
        }
        
        return names.joined(separator: ", ")
    }
    
    func omitCurrentUser() -> [Dictionary<String, AnyObject>] {
        var users = [Dictionary<String, AnyObject>]()
        for i in 0..<self.count {
            if let user = self[i] as? Dictionary<String, AnyObject> {
                let uid = user["uid"] as? String
                if (uid != Global.sharedGlobal.user?.uid) {
                    users.append(user)
                }
            }
        }

        return users
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
