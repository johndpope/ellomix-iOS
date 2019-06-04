//
//  Environment.swift
//  Ellomix
//
//  Created by Kevin Avila on 6/3/19.
//  Copyright © 2019 Ellomix. All rights reserved.
//

// https://thoughtbot.com/blog/let-s-setup-your-ios-environments

import Foundation

public enum Environment {
    // MARK: - Keys
    enum Keys {
        enum Plist {
            static let fcmServerKey = "FCMServerKey"
        }
    }

    // MARK: - Plist
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()

    // MARK: - Plist values
    static let fcmServerKey: String = {
        guard let fcmServerKey = Environment.infoDictionary[Keys.Plist.fcmServerKey] as? String else {
            fatalError("FCM Server Key not set in plist for this environment")
        }
        return fcmServerKey
    }()
}
