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
    
    // Send a notification to users of a newly created group chat
    func sendNewGroupNotification(gid: String) {
        var tokens = [String]()
        
        FirebaseAPI.getGroupsRef().child(gid).observe(.value, with: { (snapshot) in
            if var groupDict = snapshot.value as? Dictionary<String, AnyObject> {
                groupDict["gid"] = snapshot.key as AnyObject
                if let group = groupDict.toGroup() {
                    if let users = group.users {
//                        for user in users {
//                            tokens.append(user.deviceToken)
//                        }

                        // Prepare message payload
                        let message: [String: Any] = [
                            "notification": [
                                "title": "Ellomix",
                                "body": "You just got invited to a new chat"
                            ],
                            "registration_ids": tokens
                        ]

                        print("Sending message to: \(tokens)")

                        Alamofire.request(self.fcmURL, parameters: message).responseJSON(completionHandler: { response in
                            print("uccessfully sent new group creation notification for \(gid): \(response)")
                        })
                    }
                }
            }
        })
    }
}
