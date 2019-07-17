//
//  NotificationService.swift
//  Ellomix
//
//  Created by Kevin Avila on 5/16/19.
//  Copyright © 2019 Ellomix. All rights reserved.
//

import Alamofire

class NotificationService {
    
    private var FirebaseAPI: FirebaseApi = FirebaseApi()
    private let fcmURL: String = "https://fcm.googleapis.com/fcm/send"
    
    // Send a notification to users when a new message is sent in a group chat
    func sendNewMessageNotification(gid: String, sender: EllomixUser, message: Message) {
        var tokens = [String]()
        
        FirebaseAPI.getGroupsRef().child(gid).observeSingleEvent(of: .value, with: { (snapshot) in
            if var groupDict = snapshot.value as? Dictionary<String, AnyObject> {
                groupDict["gid"] = snapshot.key as AnyObject
                if let group = groupDict.toGroup() {
                    if let users = group.users {
                        for user in users {
                            // Only send to users who aren't the sender and have notifications turned on for this chat
                            if (user.uid != sender.uid && user.deviceToken != nil) {
                                tokens.append(user.deviceToken!)
                            }
                        }

                        // Set content and title for push notification
                        var content = ""
                        var title: String?
                        if (message.type == "track") {
                            content = "\(sender.name!) shared a track"

                            // If this is a group chat, set title to group name
                            if (group.name != nil) {
                                title = group.name
                            } else if (group.users != nil && group.users!.count > 2) {
                                title = group.users?.groupNameFromUsers()
                            }
                        } else if (message.type == "text" && message.content != nil) {
                            if (group.name != nil) {
                                // Group chat - set title to group name
                                title = group.name
                                content = "\(sender.name!): \(message.content!)"
                            } else if (group.users != nil && group.users!.count > 2) {
                                // Group chat with no group name - set title to name from users
                                title = group.users?.groupNameFromUsers()
                                content = "\(sender.name!): \(message.content!)"
                            } else {
                                // Single chat - set title to sender
                                title = sender.name
                                content = message.content!
                            }
                        }
                        
                        let headers: HTTPHeaders = [
                            "Content-Type": "application/json",
                            "Authorization": "key=\(Environment.fcmServerKey)"
                        ]
                        
                        // Prepare message payload
                        var params: Parameters = [
                            "notification": [
                                "body": content
                            ],
                            "registration_ids": tokens
                        ]

                        if var notificationJson = params["notification"] as? Parameters {
                            if (title != nil) {
                                notificationJson["title"] = title!
                            }

                            params["notification"] = notificationJson
                        }

                        print("Parameters: \(params)")

                        Alamofire.request(self.fcmURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
                            .validate(statusCode: 200..<300)
                            .responseJSON(completionHandler: { response in
                                switch response.result {
                                case .success(let data):
                                    print("Successfully sent new group message notification for \(gid): \(data)")
                                case .failure(let error):
                                    print("Failed sending new group message notification for \(gid): \(error.localizedDescription)")
                                }
                        })
                    }
                }
            }
        })
    }
    
    // Send a notification to a user when another user follows them
    func sendNewFollowerNotification(follower: EllomixUser, followed: EllomixUser) {
        if let deviceToken = followed.deviceToken {
            let headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "Authorization": "key=\(Environment.fcmServerKey)"
            ]
            
            // Prepare message payload
            let content = "\(follower.name!) started following you"
            let params: Parameters = [
                "notification": [
                    "body": content
                ],
                "to": deviceToken
            ]
            
            print("Parameters: \(params)")
            
            Alamofire.request(self.fcmURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .responseJSON(completionHandler: { response in
                    switch response.result {
                    case .success(let data):
                        print("Successfully sent new follower notification for \(followed.uid!): \(data)")
                    case .failure(let error):
                        print("Failed sending new group message notification for \(followed.uid!): \(error.localizedDescription)")
                    }
                })
        }
    }
    
    // Send a notification to a user when another user likes their post
    func sendNewLikeNotification(liker: EllomixUser, post: Post) {
        FirebaseAPI.getUser(uid: post.uid) { (poster) -> () in
            if let deviceToken = poster.deviceToken {
                let headers: HTTPHeaders = [
                    "Content-Type": "application/json",
                    "Authorization": "key=\(Environment.fcmServerKey)"
                ]
                
                // Prepare message payload
                let content = "\(liker.name!) liked your track"
                let params: Parameters = [
                    "notification": [
                        "body": content
                    ],
                    "to": deviceToken
                ]
                
                print("Parameters: \(params)")
                
                Alamofire.request(self.fcmURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
                    .validate(statusCode: 200..<300)
                    .responseJSON(completionHandler: { response in
                        switch response.result {
                        case .success(let data):
                            print("Successfully sent new like notification for \(poster.uid!): \(data)")
                        case .failure(let error):
                            print("Failed sending new like notification for \(poster.uid!): \(error.localizedDescription)")
                        }
                    })
            }
        }
    }
    
    // Send a notification to a user when another user comments on their post
    func sendNewCommentNotification(commenter: EllomixUser, post: Post, comment: Comment) {
        FirebaseAPI.getUser(uid: post.uid) { (poster) -> () in
            if let deviceToken = poster.deviceToken {
                let headers: HTTPHeaders = [
                    "Content-Type": "application/json",
                    "Authorization": "key=\(Environment.fcmServerKey)"
                ]
                
                // Prepare message payload
                let content = "\(commenter.name!) commented: \(comment.comment!)"
                let params: Parameters = [
                    "notification": [
                        "body": content
                    ],
                    "to": deviceToken
                ]
                
                print("Parameters: \(params)")
                
                Alamofire.request(self.fcmURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
                    .validate(statusCode: 200..<300)
                    .responseJSON(completionHandler: { response in
                        switch response.result {
                        case .success(let data):
                            print("Successfully sent new comment notification for \(poster.uid!): \(data)")
                        case .failure(let error):
                            print("Failed sending new commment notification for \(poster.uid!): \(error.localizedDescription)")
                        }
                    })
            }
        }
    }
}
