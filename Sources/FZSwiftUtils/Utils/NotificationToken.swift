//
//  NotificationToken.swift
//
//
//  Created by Florian Zand on 10.02.23.
//

import Foundation

/**
 A token representing an observer for notifications.
 
 You must keep a strong reference to the token for as long as you want to continue receiving notifications. If the token is deallocated, observation stops automatically.
 */
public class NotificationToken: NSObject {
    
    /// The name of the observed notification.
    public let name: Notification.Name?
    
    private let notificationCenter: NotificationCenter
    private let token: Any
    
    init(notificationCenter: NotificationCenter, token: Any, name: Notification.Name?) {
        self.notificationCenter = notificationCenter
        self.token = token
        self.name = name
    }
    
    /**
     Creates a notification token for observing notifications with the specified name.
     
     You must keep a strong reference to the token for as long as you want to continue receiving notifications. If the token is deallocated, observation stops automatically.
     
     - Parameters:
        - name: The name of the notification to observe.
        - object: The object to observe, or `nil` to observe from any sender.
        - notificationCenter: The notification center to use for observing.
        - queue: The operation queue on which to execute the block.
        - block: The block to execute when the notification is received.
     */
    public init(_ name: Notification.Name, object: Any? = nil, notificationCenter: NotificationCenter = .default, queue: OperationQueue? = nil, using block: @escaping (_ notification: Notification) -> Void) {
        self.notificationCenter = notificationCenter
        self.name = name
        self.token = notificationCenter.addObserver(forName: name, object: object, queue: queue, using: block)
    }
    
    /**
     Creates a notification token for observing all notifications from the specified object.
          
     You must keep a strong reference to the token for as long as you want to continue receiving notifications. If the token is deallocated, observation stops automatically.
     
     - Parameters:
        - object: The object to observe.
        - notificationCenter: The notification center to use for observing.
        - queue: The operation queue on which to execute the block.
        - block: The block to execute when the notification is received.
     */
    public init(object: Any, notificationCenter: NotificationCenter = .default, queue: OperationQueue? = nil, using block: @escaping (_ notification: Notification) -> Void) {
        self.notificationCenter = notificationCenter
        self.name = nil
        self.token = notificationCenter.addObserver(forName: nil, object: object, queue: queue, using: block)
    }

    deinit {
        notificationCenter.removeObserver(token)
    }
}

public extension NotificationCenter {
    /**
     Adds an observer for the specified notification name, and object.

     - Parameters:
        - name: The name of the notification to observe.
        - object: The object to observe, or `nil` to observe from any sender.
        - queue: The operation queue on which to execute the block.
        - block: The block to execute when the notification is received.
     - Returns: A token that represents the observation.
     
        You must keep a strong reference to the token for as long as you want to continue receiving notifications. If the token is deallocated, observation stops automatically.
     */
    func observe(_ name: Notification.Name, object: Any? = nil, queue: OperationQueue? = nil, using block: @escaping (_ notification: Notification) -> Void)  -> NotificationToken {
        NotificationToken(name, object: object, notificationCenter: self, queue: queue, using: block)
    }
    
    /**
     Adds an observer for observing all notifications from the specified object.
     
     - Parameters:
        - object: The object to observe.
        - queue: The operation queue on which to execute the block.
        - block: The block to execute when the notification is received.
     - Returns: A token that represents the observation.
     
        You must keep a strong reference to the token for as long as you want to continue receiving notifications. If the token is deallocated, observation stops automatically.
     */
    func observe(_ object: Any, queue: OperationQueue? = nil, using block: @escaping (_ notification: Notification) -> Void)  -> NotificationToken {
        NotificationToken(object: object, notificationCenter: self, queue: queue, using: block)
    }
}

public extension NSObjectProtocol where Self: NSObject {
    /**
     Observes all notifications with the specified name posted by this object.

     You must keep a strong reference to the token for as long as you want to continue receiving notifications. If the token is deallocated, observation stops automatically.

     - Parameters:
        - keyPath: The key path to the notification name to observe.
        - queue: The operation queue on which to execute the block.
        - block: The block to execute when the notification is received.
     - Returns: A token that represents the observation.
     */
    func observeNotification(for keyPath: KeyPath<Self.Type, Notification.Name>, queue: OperationQueue? = nil, using block: @escaping (_ notification: Notification) -> Void) -> NotificationToken {
        observeNotification(for: Self.self[keyPath: keyPath], queue: queue, using: block)
    }
    
    /**
     Observes all notifications with the specified name posted by this object.

     You must keep a strong reference to the token for as long as you want to continue receiving notifications. If the token is deallocated, observation stops automatically.

     - Parameters:
        - keyPath: The key path to the notification name to observe.
        - queue: The operation queue on which to execute the block.
        - block: The block to execute when the notification is received.
     - Returns: A token that represents the observation.
     */
    func observeNotification(for name: Notification.Name, queue: OperationQueue? = nil, using block: @escaping (_ notification: Notification) -> Void) -> NotificationToken {
        NotificationCenter.default.observe(name, object: self, queue: queue, using: block)
    }
    
    /**
     Observes all notifications with the specified name posted by any instance of this class.

     You must keep a strong reference to the token for as long as you want to continue receiving notifications. If the token is deallocated, observation stops automatically.

     - Parameters:
        - keyPath: The key path to the notification name to observe.
        - queue: The operation queue on which to execute the block.
        - block: The block to execute when the notification is received.
     - Returns: A token that represents the observation.
     */
    static func observeNotification(for keyPath: KeyPath<Self.Type, Notification.Name>, queue: OperationQueue? = nil, using block: @escaping (_ notification: Notification) -> Void) -> NotificationToken {
        observeNotification(for: Self.self[keyPath: keyPath], queue: queue, using: block)
    }
    
    /**
     Observes all notifications with the specified name posted by any instance of this class.
     
     You must keep a strong reference to the token for as long as you want to continue receiving notifications. If the token is deallocated, observation stops automatically.

     - Parameters:
        - keyPath: The key path to the notification name to observe.
        - queue: The operation queue on which to execute the block.
        - block: The block to execute when the notification is received.
     - Returns: A token that represents the observation.
     */
    static func observeNotification(for name: Notification.Name, queue: OperationQueue? = nil, using block: @escaping (_ notification: Notification) -> Void) -> NotificationToken {
        NotificationCenter.default.observe(name, queue: queue) { notification in
            guard notification.object is Self.Type else { return }
            block(notification)
        }
    }
}

public extension RangeReplaceableCollection where Element: NotificationToken {
    /// Removes all notification tokens that are observing notifications with the specified name.
    mutating func remove(_ name: Notification.Name) {
        removeAll(where: { $0.name == name })
    }
    
    /// Removes all notification tokens that are observing notifications with the specified names.
    mutating func remove<S>(_ names: S) where S: Sequence<Notification.Name> {
        removeAll(where: { if let name = $0.name { return names.contains(name) } else { return false } })
    }
}
