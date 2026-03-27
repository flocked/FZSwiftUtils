//
//  Notification+.swift
//
//
//  Created by Florian Zand on 07.12.24.
//

import Foundation
#if os(macOS)
import AppKit
#endif

extension Notification.Name: Swift.ExpressibleByStringLiteral, Swift.ExpressibleByUnicodeScalarLiteral, Swift.ExpressibleByExtendedGraphemeClusterLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}


extension Notification {
    /// Values of this notification.
    public var values: Info {
        Info(for: self)
    }
  
    /// Values of a notification.
    public struct Info {
        private let notification: Notification

        fileprivate init(for notification: Notification) {
            self.notification = notification
        }
    
        /// Values of notifications posted by the specified object type.
        public subscript<V>(_ type: V.Type) -> Values<V> {
            Values(for: notification)
        }
    }
}

extension Notification.Info {
    /// Values for a Notification.
    public struct Values<Object> {
        private let notification: Notification
    
        fileprivate init(for notification: Notification) {
            self.notification = notification
        }
    
        private func matches(_ keyPaths: KeyPath<Object.Type, Notification.Name>...) -> Bool {
            keyPaths.contains(where: { notification.name == Object.self[keyPath: $0] })
        }
    
        private func matches(_ keyPaths: KeyPath<Notification.Name.Type, Notification.Name>...) -> Bool {
            keyPaths.contains(where: { notification.name == Notification.Name.self[keyPath: $0] })
        }
    
        private var object: Object? {
            notification.object as? Object
        }
    
        private subscript<V>(key: AnyHashable) -> V? {
            notification.userInfo?[key] as? V
        }
    
        private subscript(key: AnyHashable) -> Any? {
            notification.userInfo?[key]
        }
    }
}

#if os(macOS)
public extension Notification.Info {
    /// Values of notifications posted by `NSTableView`.
    var tableView: Values<NSTableView> { Values(for: notification) }
    
    /// Values of notifications posted by `NSOutlineView`.
    var outlineView: Values<NSOutlineView> { Values(for: notification) }
    
    /// Values of notifications posted by `NSMenu`.
    var menu: Values<NSMenu> { Values(for: notification) }
    
    /// Values of notifications posted by `NSMetadataQuery`.
    var metadataQuery: Values<NSMetadataQuery> { Values(for: notification) }
    
    /// Values of notifications posted by `NSText`.
    var text: Values<NSText> { Values(for: notification) }
    
    /// Values of notifications posted by `NSTextField`.
    var textField: Values<NSTextField> { Values(for: notification) }
    
    /// Values of notifications posted by `NSTextView`.
    var textView: Values<NSTextView> { Values(for: notification) }
    
    /// Values of notifications posted by `NSWorkspace`.
    var workspace: Values<NSWorkspace> { Values(for: notification) }
    
    /// Values of notifications posted by `NSSplitView`.
    var splitView: Values<NSSplitView> { Values(for: notification) }
}

public extension Notification.Info.Values where Object: NSMenu {
    /// The item that has been added, changed, will send or did send it's action.
    var item: NSMenuItem? {
        if matches(\.didAddItemNotification, \.didChangeItemNotification) {
            return object?.items[safe: self["NSMenuItemIndex"] ?? -1]
        }
        return matches(\.willSendActionNotification, \.didSendActionNotification) ? self["MenuItem"] : nil
    }
  
    /// The index of the item that has been added, changed or removed.
    var itemIndex: Int? {
        matches(\.didRemoveItemNotification, \.didAddItemNotification, \.didChangeItemNotification) ? self["NSMenuItemIndex"] : nil
    }
}

public extension Notification.Info.Values where Object: NSTableView {
    /// The table column that has been moved.
    var movedColumn: MovedColumnInfo? {
        guard matches(\.columnDidMoveNotification), let old: Int = self["NSOldColumn"], let new: Int = self["NSNewColumn"], let column = object?.tableColumns[safe: new] else { return nil }
        return MovedColumnInfo(column: column, oldIndex: old, newIndex: new)
    }
    
    /// Values of a moved table column.
    struct MovedColumnInfo {
        /// The column that was moved.
        public let column: NSTableColumn
        /// The previous index of the column.
        public let oldIndex: Int
        /// The current index of the column.
        public let newIndex: Int

    }
  
    /// The table column that has been resized.
    var resizedColumn: ResizedColumnInfo? {
        guard matches(\.columnDidResizeNotification), let column: NSTableColumn = self["NSTableColumn"], let oldWidth: CGFloat = self["NSOldWidth"] else { return nil }
        return ResizedColumnInfo(column: column, oldWidth: oldWidth)
    }
    
    /// Values of a resized table column.
    struct ResizedColumnInfo {
        /// The column that was resized.
        public let column: NSTableColumn
        /// The previous width of the column.
        public let oldWidth: CGFloat
    }
}

public extension Notification.Info.Values where Object: NSOutlineView {
    /// The outline view item that will / did expand or collapse.
    var item: Any? {
        matches(\.itemWillExpandNotification, \.itemDidExpandNotification, \.itemWillCollapseNotification, \.itemDidCollapseNotification) ? self["NSObject"] : nil
    }
}

public extension Notification.Info.Values where Object: NSText {
    /// The text movement of a `didEndEditingNotification` notification.
    var textMovement: NSTextMovement? {
        matches(\.didEndEditingNotification) ? self[NSText.movementUserInfoKey] : nil
    }
}

public extension Notification.Info.Values where Object: NSTextView {
    /// The previous selection range.
    var oldSelectionRange: NSRange? {
        matches(\.didChangeSelectionNotification) ? self["NSOldSelectedCharacterRange"] : nil
    }
  
    /// The previous selected string value.
    var oldSelection: String? {
        guard let range = oldSelectionRange, let object = object else { return nil }
        return String(object.string[range])
    }
}

public extension Notification.Info.Values where Object: NSTextField {
    /// The field editor.
    var fieldEditor: NSText? {
        matches(\.textDidBeginEditingNotification, \.textDidChangeNotification, \.textDidEndEditingNotification) ? self["NSFieldEditor"] : nil
    }
}

public extension Notification.Info.Values where Object: NSWorkspace {
    /// The URL of the device that will / did mount or unmount.
    var deviceURL: URL? {
        guard matches(\.didUnmountNotification, \.willUnmountNotification, \.didMountNotification), let path: String = self["NSDevicePath"] else { return nil }
        return URL(filePath: path)
    }
}

public extension Notification.Info.Values where Object: NSSplitView {
    /// The divider that the split view or user moves.
    var movedDivider: DividerMoveInfo? {
        guard matches(\.didResizeSubviewsNotification, \.willResizeSubviewsNotification), let index: Int = self["NSSplitViewDividerIndex"] else { return nil }
        return DividerMoveInfo(index: index, byUser: self["NSSplitViewUserResizeKey"] as? Int == 1)
    }
    
    /// Values of a divider that moves.
    struct DividerMoveInfo {
        /// The index of the divider that moves.
        public let index: Int
        /// A Boolean value indicating whether the user or split view moves the divider.
        public let byUser: Bool
    }
}

public extension Notification.Info.Values where Object: NSMetadataQuery {
    /// The items added to, removed from and changed in the query result.
    func itemsUpdate<V>(as type: V.Type = NSMetadataItem.self) -> (added: [V], removed: [V], changed: [V]) {
        (self[NSMetadataQueryUpdateAddedItemsKey] ?? [], self[NSMetadataQueryUpdateRemovedItemsKey] ?? [], self[NSMetadataQueryUpdateChangedItemsKey] ?? [])
    }
    
    /// The items added to, removed from and changed in the query result.
    func itemsUpdate<V>() -> (added: [V], removed: [V], changed: [V]) {
        (self[NSMetadataQueryUpdateAddedItemsKey] ?? [], self[NSMetadataQueryUpdateRemovedItemsKey] ?? [], self[NSMetadataQueryUpdateChangedItemsKey] ?? [])
    }
}
#endif
