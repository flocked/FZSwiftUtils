//
//  OutlineItem.swift
//  OutlineItem
//
//  Created by Florian Zand on 06.11.21.
//

import Foundation

public protocol OutlineItem {
    var isExpandable: Bool { get }
    var children: [any OutlineItem] { get set }
}

public extension OutlineItem {
    var isExpandable: Bool {
        return (children.isEmpty == false)
    }
}

public protocol ExpandingOutlineItem {
    var isExpandable: Bool { get }
    var isExpanded: Bool { get set }
    var children: [any ExpandingOutlineItem] { get set }
}

public extension ExpandingOutlineItem {
    var isExpandable: Bool {
        return (children.isEmpty == false)
    }
}

public extension ExpandingOutlineItem {
    mutating func expandAll(includingSubchildren: Bool = false) {
        children.editEach({
            $0.isExpanded = true
            if includingSubchildren {
                $0.expandAll(includingSubchildren: true)
            }
        })
    }
    
    mutating func collapseAll(includingSubchildren: Bool = false) {
        children.editEach({
            $0.isExpanded = false
            if includingSubchildren {
                $0.collapseAll(includingSubchildren: true)
            }
        })
    }
}
