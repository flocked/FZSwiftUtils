//
//  NSKeyValueChangeKey+.swift
//
//
//  Created by Florian Zand on 18.07.26.
//

import Foundation

public extension [NSKeyValueChangeKey: Any] {
    /**
     The new value associated with the observed change.

     For collection changes, this contains the inserted or replacement objects.
     */
    var newValue: Any? { self[.newKey] }
    /**
     The previous value associated with the observed change.

     For collection changes, this contains the removed or replaced objects.
     */
    var oldValue: Any? { self[.oldKey] }
    /**
     A Boolean value indicating whether this notification was sent before the change occurred.

     Returns `true` only for prior notifications.
     */
    var isPrior: Bool { self[.notificationIsPriorKey] as? Bool ?? false }
    /**
     The type of change that occurred.

     The value indicates whether the change was a setting, insertion, removal, or replacement.
     */
    var kind: NSKeyValueChange { .init(rawValue: self[.kindKey] as? UInt ?? 1) ?? .setting }
    /**
     The indexes affected by a collection change.

     Available only for insertion, removal, and replacement changes.
     */
    var indexes: IndexSet? { self[.indexesKey] as? IndexSet }
}
