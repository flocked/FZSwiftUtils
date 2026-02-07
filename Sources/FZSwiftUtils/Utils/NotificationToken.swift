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
    
    fileprivate let notificationCenter: NotificationCenter
    private let token: Any
    
    /**
     Creates a token for observing notifications with the specified name.
          
     You must keep the token alive for as long as you want to observe notifications. If the token is deallocated, observation stops automatically.

     - Parameters:
        - name: The name of the notification to observe.
        - object: The object to observe notifications from, or `nil` to observe all notifications with the name.
        - notificationCenter: The notification center to use for observing.
        - queue: The operation queue on which to execute the block.
        - block: The closure to run when a matching notification is posted.
´     */
    public init(_ name: Notification.Name, object: Any? = nil, notificationCenter: NotificationCenter = .default, queue: OperationQueue? = nil, block: @escaping (_ notification: Notification) -> Void) {
        self.notificationCenter = notificationCenter
        self.name = name
        self.token = notificationCenter.addObserver(forName: name, object: object, queue: queue, using: block)
    }
    
    /**
     Creates a token for observing all notifications from the specified object.
           
     You must keep the token alive for as long as you want to observe notifications. If the token is deallocated, observation stops automatically.

     - Parameters:
        - object: The object to observe notifications from
        - notificationCenter: The notification center to use for observing.
        - queue: The operation queue on which to execute the block.
        - block: The closure to run when a matching notification is posted.
     */
    public init(object: Any, notificationCenter: NotificationCenter = .default, queue: OperationQueue? = nil, block: @escaping (_ notification: Notification) -> Void) {
        self.notificationCenter = notificationCenter
        self.name = nil
        self.token = notificationCenter.addObserver(forName: nil, object: object, queue: queue, using: block)
    }
    
    init(tokens: [NotificationToken]) {
        name = .init(tokens.compactMap({$0.name?.rawValue}).joined(separator: ", "))
        token = tokens
        notificationCenter = .default
    }

    deinit {
        guard !(token is [NotificationToken]) else { return }
        notificationCenter.removeObserver(token)
    }
}

public extension NotificationCenter {
    /**
     Observes notifications with the specified name posted by the given object.

     You must keep the returned token alive for as long as you want to observe notifications. If the token is deallocated, observation stops automatically.

     - Parameters:
        - name: The name of the notification to observe.
        - object: The object to observe notifications from, or `nil` to observe all notifications with the name.
        - queue: The operation queue on which to execute the block.
        - block: The closure to run when a matching notification is posted.
     - Returns: A token that keeps the observation alive and removes it on deallocation.
     */
    func observe(_ name: Notification.Name, postedBy object: Any? = nil, on queue: OperationQueue? = nil, using block: @escaping (_ notification: Notification) -> Void)  -> NotificationToken {
        NotificationToken(name, object: object, notificationCenter: self, queue: queue, block: block)
    }
    
    /**
     Observes all notifications from the specified object.
     
     You must keep the returned token alive for as long as you want to observe notifications. If the token is deallocated, observation stops automatically.

     - Parameters:
        - object: The object to observe notifications from.
        - queue: The operation queue on which to execute the block.
        - block: The closure to run when notifications are posted by the object.
     - Returns: A token that keeps the observation alive and removes it on deallocation.
     */
    func observe(_ object: Any, on queue: OperationQueue? = nil, using block: @escaping (_ notification: Notification) -> Void)  -> NotificationToken {
        NotificationToken(object: object, notificationCenter: self, queue: queue, block: block)
    }
}

public extension NSObjectProtocol where Self: NSObject {
    /**
     Observes notifications with the specified name posted by this object.

     You must keep the returned token alive for as long as you want to observe notifications. If the token is deallocated, observation stops automatically.

     - Parameters:
        - keyPath: The key path to the notification name to observe.
        - queue: The operation queue on which to execute the block.
        - block: The block to execute when the notification is received.
     - Returns: A token that keeps the observation alive and removes it on deallocation.
     */
    func observe(_ keyPath: KeyPath<Self.Type, Notification.Name>, on queue: OperationQueue? = nil, using block: @escaping (_ notification: Notification) -> Void) -> NotificationToken {
        observe(Self.self[keyPath: keyPath], on: queue, using: block)
    }
    
    /**
     Observes all notifications with the specified name posted by this object.

     You must keep the returned token alive for as long as you want to observe notifications. If the token is deallocated, observation stops automatically.

     - Parameters:
        - name: The name of the notification to observe.
        - queue: The operation queue on which to execute the block.
        - block: The block to execute when the notification is received.
     - Returns: A token that keeps the observation alive and removes it on deallocation.
     */
    func observe(_ name: Notification.Name, on queue: OperationQueue? = nil, using block: @escaping (_ notification: Notification) -> Void) -> NotificationToken {
        NotificationCenter.default.observe(name, postedBy: self, on: queue, using: block)
    }
    
    /**
     Observes all notifications with the specified name posted by any instance of this class.

     You must keep the returned token alive for as long as you want to observe notifications. If the token is deallocated, observation stops automatically.

     - Parameters:
        - keyPath: The key path to the notification name to observe.
        - queue: The operation queue on which to execute the block.
        - block: The block to execute when the notification is received.
     - Returns: A token that keeps the observation alive and removes it on deallocation.
     */
    static func observe(_ keyPath: KeyPath<Self.Type, Notification.Name>, on queue: OperationQueue? = nil, using block: @escaping (_ notification: Notification) -> Void) -> NotificationToken {
        observe(Self.self[keyPath: keyPath], on: queue, using: block)
    }
    
    /**
     Observes all notifications with the specified name posted by any instance of this class.
     
     You must keep the returned token alive for as long as you want to observe notifications. If the token is deallocated, observation stops automatically.

     - Parameters:
        - name: The name of the notification to observe.
        - queue: The operation queue on which to execute the block.
        - block: The block to execute when the notification is received.
     - Returns: A token that keeps the observation alive and removes it on deallocation.
     */
    static func observe(_ name: Notification.Name, on queue: OperationQueue? = nil, using block: @escaping (_ notification: Notification) -> Void) -> NotificationToken {
        NotificationCenter.default.observe(name, postedBy: nil, on: queue) {
            guard $0.object is Self else { return }
            block($0)
        }
    }
}

public extension NSObjectProtocol where Self: NSObject {
    /**
     Observes all notifications with the specified names posted by this object.

     You must keep the returned token alive for as long as you want to observe notifications. If the token is deallocated, observation stops automatically.

     - Parameters:
        - keyPaths: The key paths to the notification names to observe.
        - queue: The operation queue on which to execute the block.
        - block: The block to execute when the notification is received.
     - Returns: A token that keeps the observation alive and removes it on deallocation.
     */
    func observe(_ keyPaths: [KeyPath<Self.Type, Notification.Name>], on queue: OperationQueue? = nil, using block: @escaping (_ notification: Notification) -> Void) -> NotificationToken {
        NotificationToken(tokens: keyPaths.map({ observe($0, on: queue, using: block) }))
    }
    
    /**
     Observes all notifications with the specified names posted by this object.

     You must keep the returned token alive for as long as you want to observe notifications. If the token is deallocated, observation stops automatically.

     - Parameters:
        - names: The names of the notifications to observe.
        - queue: The operation queue on which to execute the block.
        - block: The block to execute when the notification is received.
     - Returns: A token that keeps the observation alive and removes it on deallocation.
     */
    func observe(_ names: [Notification.Name], on queue: OperationQueue? = nil, using block: @escaping (_ notification: Notification) -> Void) -> NotificationToken {
        NotificationToken(tokens: names.map({observe($0, on: queue, using: block) }))
    }
    
    /**
     Observes all notifications with the specified names posted by any instance of this class.

     You must keep the returned token alive for as long as you want to observe notifications. If the token is deallocated, observation stops automatically.

     - Parameters:
        - keyPaths: The key paths to the notification names to observe.
        - queue: The operation queue on which to execute the block.
        - block: The block to execute when the notification is received.
     - Returns: A token that keeps the observation alive and removes it on deallocation.
     */
    static func observe(_ keyPaths: [KeyPath<Self.Type, Notification.Name>], on queue: OperationQueue? = nil, using block: @escaping (_ notification: Notification) -> Void) -> NotificationToken {
        NotificationToken(tokens: keyPaths.map({ observe($0, on: queue, using: block) }))
    }
    
    /**
     Observes all notifications with the specified names posted by any instance of this class.
     
     You must keep the returned token alive for as long as you want to observe notifications. If the token is deallocated, observation stops automatically.

     - Parameters:
        - names: The names of the notifications to observe.
        - queue: The operation queue on which to execute the block.
        - block: The block to execute when a notification is received.
     - Returns: A token that keeps the observation alive and removes it on deallocation.
     */
    static func observe(_ names: [Notification.Name], on queue: OperationQueue? = nil, using block: @escaping (_ notification: Notification) -> Void) -> NotificationToken {
        NotificationToken(tokens: names.map({observe($0, on: queue, using: block) }))
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

extension Notification.Name {
    /**
     Observes notifications with this name by the specified posting object.
     
     You must keep the returned token alive for as long as you want to observe notifications. If the token is deallocated, observation stops automatically.

     - Parameters:
        - object: The object to observe notifications from.
        - queue: The operation queue on which to execute the block.
        - block: The closure to run when a matching notification is posted.
     - Returns: A token that keeps the observation alive and removes it on deallocation.
     */
    func observe(_ object: Any, on queue: OperationQueue? = nil, using block: @escaping (Notification) -> ()) -> NotificationToken {
        .init(self, object: object, queue: queue, block: block)
    }
    
    /**
     Observes notifications with this name from any posting object.

     You must keep the returned token alive for as long as you want to observe notifications. If the token is deallocated, observation stops automatically.

     - Parameters:
        - queue: The operation queue on which to execute the block.
        - block: The closure to run when a matching notification is posted.
     - Returns: A token that keeps the observation alive and removes it on deallocation.
     */
    func observe(on queue: OperationQueue? = nil, using block: @escaping (Notification) -> ()) -> NotificationToken {
        .init(self, queue: queue, block: block)
    }
}
