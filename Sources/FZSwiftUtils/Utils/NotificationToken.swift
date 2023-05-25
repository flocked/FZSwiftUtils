//
//  NotificationToken.swift
//  NotificationToken
//
//  Created by Florian Zand on 10.02.23.
//

import Foundation

public class NotificationToken: NSObject {
    let notificationCenter: NotificationCenter
    let token: Any

   public init(notificationCenter: NotificationCenter = .default, token: Any) {
        self.notificationCenter = notificationCenter
        self.token = token
    }

    deinit {
        notificationCenter.removeObserver(token)
    }
}

public extension NotificationCenter {
    func observe(name: NSNotification.Name?, object obj: Any?,
        queue: OperationQueue?, using block: @escaping (Notification) -> ())
        -> NotificationToken {
        let token = addObserver(forName: name, object: obj, queue: queue, using: block)
        return NotificationToken(notificationCenter: self, token: token)
    }
}
