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
                            if (user.uid != sender.uid) {
                                tokens.append(user.deviceToken)
                            }
                        }

                        var content = message.content
                        if (content == nil) {
                            content = ""
                        }
                        
                        let headers: HTTPHeaders = [
                            "Content-Type": "application/json",
                            "Authorization": "key=\(Environment.fcmServerKey)"
                        ]
                        
                        // Prepare message payload
                        let params: Parameters = [
                            "notification": [
                                "title": sender.name,
                                "body": content!
                            ],
                            "registration_ids": tokens
                        ]

                        print("Message title: \(sender.name)")
                        print("Message conent: \(content!)")
                        print("Sending message to: \(tokens)")

                        Alamofire.request(self.fcmURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
                            .validate(statusCode: 200..<300)
                            .responseJSON(completionHandler: { response in
                                print(response)
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
}
