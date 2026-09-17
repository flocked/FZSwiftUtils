//
//  NotificationCenter+.swift
//
//
//  Created by Florian Zand on 17.09.26.
//

import Foundation

public extension NotificationCenter {
    /**
     Creates a notification with a given name and posts it to the notification center.
     
     - Parameter name: The name of the notification.
     */
    func post(name: Notification.Name) {
        post(name: name, object: nil)
    }
    
    /**
     Creates a notification with a given name and information and posts it to the notification center.
     
     - Parameters:
        - name: The name of the notification.
        - userInfo: A user info dictionary with optional information about the notification.
     */
    func post(name: Notification.Name, userInfo: [AnyHashable : Any]) {
        post(name: name, object: nil, userInfo: userInfo)
    }
}

public extension NSObjectProtocol where Self: NSObject {
    /**
     Posts a notification with the specified name to the default notification center.
     
     - Parameters:
       - name: The name of the notification.
       - userInfo: Information to include with the notification.
     */
    func postNotification(_ name: Notification.Name, userInfo: [AnyHashable: Any]? = nil) {
        NotificationCenter.default.post(name: name, object: self, userInfo: userInfo)
    }
}

#if os(macOS)
import AppKit

public extension NSObjectProtocol where Self: NSWorkspace {
    /**
     Posts a notification with the specified name to the workspace notification center.
     
     - Parameters:
       - name: The name of the notification.
       - userInfo: Information to include with the notification.
     */
    func postNotification(_ name: Notification.Name, userInfo: [AnyHashable: Any]? = nil) {
        notificationCenter.post(name: name, object: self, userInfo: userInfo)
    }
}
#endif
