//
//  OutlineItem.swift
//
//
//  Created by Florian Zand on 06.11.21.
//

import Foundation

/// A type that represents an expandable item.
public protocol OutlineItem: Hashable {
    /// A Boolean value indicating whether the item is expandable.
    var isExpandable: Bool { get }
    /// An array of child outline items.
    var children: [Self] { get }
    /// The root item.
    static var root: Self { get }
}

public extension OutlineItem {
    var isExpandable: Bool {
        children.isEmpty == false
    }

    func parent(of member: Self) -> Self? {
        for child in children {
            if child == member { return self }
            if let p = child.parent(of: member) { return p }
        }
        return nil
    }

    func search(for item: Self) -> Self? {
        if item == self { return self }
        for child in children {
            if let hit = child.search(for: item) {
                return hit
            }
        }
        return nil
    }

    func indexPath(of item: Self) -> IndexPath? {
        for (idx, child) in children.indexed() {
            if child == item {
                return IndexPath(indexes: [idx])
            } else if let childIP = child.indexPath(of: item) {
                return IndexPath(indexes: [idx]).appending(childIP)
            }
        }
        return nil
    }
}

/// A type that represents an expandable item.
public protocol ExpandingOutlineItem: Hashable {
    /// A Boolean value indicating whether the item is expandable.
    var isExpandable: Bool { get set }
    /// A Boolean value indicating whether the item is expanded.
    var isExpanded: Bool { get set }
    /// An array of child outline items.
    var children: [Self] { get set }
    /// The root item.
    static var root: Self { get }
}

public extension ExpandingOutlineItem {
    var isExpandable: Bool {
        children.isEmpty == false
    }

    func parent(of member: Self) -> Self? {
        for child in children {
            if child == member { return self }
            if let p = child.parent(of: member) { return p }
        }
        return nil
    }

    func search(for item: Self) -> Self? {
        if item == self { return self }
        for child in children {
            if let hit = child.search(for: item) {
                return hit
            }
        }
        return nil
    }

    func indexPath(of item: Self) -> IndexPath? {
        for (idx, child) in children.indexed() {
            if child == item {
                return IndexPath(indexes: [idx])
            } else if let childIP = child.indexPath(of: item) {
                return IndexPath(indexes: [idx]).appending(childIP)
            }
        }
        return nil
    }
}

public extension ExpandingOutlineItem {
    /**
     Expands the current item and optionally expands all subchildren as well.

     - Parameter includingSubchildren: A Boolean value indicating whether to expand all subchildren. The default value is `false`.
     */
    mutating func expandAll(includingSubchildren: Bool = false) {
        children.editEach {
            $0.isExpanded = true
            if includingSubchildren {
                $0.expandAll(includingSubchildren: true)
            }
        }
    }

    /**
     Collapses the current item and optionally collapses all subchildren as well.

     - Parameter includingSubchildren: A Boolean value indicating whether to collapse all subchildren. The default value is `false`.
     */
    mutating func collapseAll(includingSubchildren: Bool = false) {
        children.editEach {
            $0.isExpanded = false
            if includingSubchildren {
                $0.collapseAll(includingSubchildren: true)
            }
        }
    }
}
