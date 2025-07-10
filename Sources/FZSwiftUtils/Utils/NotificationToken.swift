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
    
    /**
     Creates a notification token for observing the notification with the specified name.
     
     - Parameters:
        - name: The name of the notification to observe, or `nil` to receive notifications for all names.
        - object: The object to observe.
        - notificationCenter: The notification center to use for observing.
        - queue: The operation queue on which to execute the block, or `nil` to  use the default queue.
        - block: The block to execute when the notification is received.
     */
    public init(_ name: NSNotification.Name?, object: Any, notificationCenter: NotificationCenter = .default, queue: OperationQueue? = nil, using block: @escaping (_ notification: Notification) -> Void) {
        self.notificationCenter = notificationCenter
        self.name = name
        self.token = notificationCenter.addObserver(forName: name, object: object, queue: queue, using: block)
    }
    
    /**
     Creates a notification token for observing all notifications with the specified name.
     
     - Parameters:
        - name: The name of the notification to observe, or `nil` to receive notifications for all names.
        - notificationCenter: The notification center to use for observing.
        - queue: The operation queue on which to execute the block, or `nil` to  use the default queue.
        - block: The block to execute when the notification is received.
     */
    public init(_ name: NSNotification.Name?, notificationCenter: NotificationCenter = .default, queue: OperationQueue? = nil, using block: @escaping (_ notification: Notification) -> Void) {
        self.notificationCenter = notificationCenter
        self.name = name
        self.token = notificationCenter.addObserver(forName: name, object: nil, queue: queue, using: block)
    }

    deinit {
        notificationCenter.removeObserver(token)
    }
}

public extension NotificationCenter {
    /**
     Adds an observer for the specified notification name, object, queue, and block.

     - Parameters:
        - name: The name of the notification to observe, or `nil` to receive notifications for all names.
        - object: The object to observe.
        - queue: The operation queue on which to execute the block, or `nil` to  use the default queue.
        - block: The block to execute when the notification is received.

     - Returns: A `NotificationToken` that represents the observer. You can use this token to remove the observer later.
     */
    func observe(_ name: NSNotification.Name?, object: Any, queue: OperationQueue? = nil, using block: @escaping (_ notification: Notification) -> Void)  -> NotificationToken {
        NotificationToken(name, object: object, notificationCenter: self, queue: queue, using: block)
    }
    
    /**
     Adds an observer for the specified notification name, queue, and block.

     - Parameters:
        - name: The name of the notification to observe, or `nil` to receive notifications for all names.
        - queue: The operation queue on which to execute the block, or `nil` to  use the default queue.
        - block: The block to execute when the notification is received.

     - Returns: A `NotificationToken` that represents the observer. You can use this token to remove the observer later.
     */
    func observe(_ name: NSNotification.Name?, queue: OperationQueue? = nil, using block: @escaping (_ notification: Notification) -> Void)  -> NotificationToken {
        NotificationToken(name, notificationCenter: self, queue: queue, using: block)
    }
}

/// A notification token that combines multiple notification tokens.
class CombinedNotificationToken: NotificationToken {
    let tokens: [NotificationToken]
    
    init?(_ tokens: [NotificationToken]) {
        guard !tokens.isEmpty, tokens.compactMap({$0.notificationCenter}).uniqued().count == 1 else { return nil }
        let token = tokens.first!
        self.tokens = tokens
        super.init(notificationCenter: token.notificationCenter, token: token.token, name: token.name)
    }
    
    deinit {
        
    }
}

public extension Collection where Element: NotificationToken {
    /// Returns a combined notification token for the tokens of the sequence.
    var combinedNotificationToken: NotificationToken? {
        count == 1 ? first : CombinedNotificationToken(Array(self))
    }
}


public extension Array where Element: NotificationToken {
    mutating func remove(_ name: Notification.Name) {
        self.removeAll(where: { $0.name == name })
    }
    
    mutating func remove<S>(_ names: S) where S: Sequence<Notification.Name> {
        self.removeAll(where: { if let name = $0.name { return names.contains(name) } else { return false } })
    }

}
