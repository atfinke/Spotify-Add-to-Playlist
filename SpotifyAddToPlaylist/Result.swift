//
//  Result.swift
//  SpotifyAddToPlaylist
//
//  Created by Andrew Finke on 9/18/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//

import Foundation

struct Result {

    static func error(_ message: String) {
        let notification = NSUserNotification()
        notification.title = "Failed To Save Track"
        notification.subtitle = message
        let notificationCenter = NSUserNotificationCenter.default
        notificationCenter.deliver(notification)
        exit(0)
    }

    static func success(_ message: String) {
        let notification = NSUserNotification()
        notification.title = "Saved Track"
        notification.subtitle = message
        let notificationCenter = NSUserNotificationCenter.default
        notificationCenter.deliver(notification)
        exit(0)
    }

}
