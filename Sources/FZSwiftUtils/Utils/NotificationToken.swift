//
//  NotificationToken.swift
//
//
//  Created by Florian Zand on 10.02.23.
//

import Foundation

/**
 A token representing an observer for notifications.

 The notification is observed until you deallocate the token.
 */
public class NotificationToken: NSObject {
    
    /// The name of the observed notification.
    public let name: NSNotification.Name?
    
    let notificationCenter: NotificationCenter

    let token: Any

    init(notificationCenter: NotificationCenter, token: Any, name: NSNotification.Name?) {
        self.notificationCenter = notificationCenter
        self.token = token
        self.name = name
    }

    deinit {
        notificationCenter.removeObserver(token)
    }
}

public extension NotificationCenter {
    /**
     Adds an observer for the specified notification name, object, queue, and block.

     - Parameters:
       - name: The name of the notification to observe. Pass `nil` to receive notifications for all names.
       - object: The object to observe. Pass `nil` to receive notifications from any object.
       - queue: The operation queue on which to execute the block. The default value is `nil` which uses the default queue.
       - block: The block to execute when the notification is received. The block takes a single parameter of type `Notification`.

     - Returns: A `NotificationToken` that represents the observer. You can use this token to remove the observer later.
     */
    func observe(_ name: NSNotification.Name?, object: Any?, queue: OperationQueue? = nil, using block: @escaping (Notification) -> Void)  -> NotificationToken {
        let token = addObserver(forName: name, object: object, queue: queue, using: block)
        return NotificationToken(notificationCenter: self, token: token, name: name)
    }
    
    /**
     Adds an observer for the specified notification name, queue, and block.

     - Parameters:
       - name: The name of the notification to observe. Pass `nil` to receive notifications for all names.
       - queue: The operation queue on which to execute the block. The default value is `nil` which uses the default queue.
       - block: The block to execute when the notification is received. The block takes a single parameter of type `Notification`.

     - Returns: A `NotificationToken` that represents the observer. You can use this token to remove the observer later.
     */
    func observe(_ name: NSNotification.Name?, queue: OperationQueue? = nil, using block: @escaping (Notification) -> Void)  -> NotificationToken {
        let token = addObserver(forName: name, object: nil, queue: queue, using: block)
        return NotificationToken(notificationCenter: self, token: token, name: name)
    }
}
