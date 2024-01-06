//
//  OutlineItem.swift
//  
//
//  Created by Florian Zand on 06.11.21.
//

import Foundation

/// A type that represents an expandable item.
public protocol OutlineItem {
    /// A Boolean value indicating whether the item is expandable.
    var isExpandable: Bool { get }
    /// An array of child outline items.
    var children: [Self] { get }
}

public extension OutlineItem {
    var isExpandable: Bool {
        return (children.isEmpty == false)
    }
}

/// A type that represents an expandable item.
public protocol ExpandingOutlineItem {
    /// A Boolean value indicating whether the item is expandable.
    var isExpandable: Bool { get }
    /// A Boolean value indicating whether the item is expanded.
    var isExpanded: Bool { get set }
    /// An array of child outline items.
    var children: [Self] { get set }
}

public extension ExpandingOutlineItem {
    var isExpandable: Bool {
        return (children.isEmpty == false)
    }
}

public extension ExpandingOutlineItem {
    /**
     Expands the current item and optionally expands all subchildren as well.
     
     - Parameter includingSubchildren: A Boolean value indicating whether to expand all subchildren. The default value is `false`.
     */
    mutating func expandAll(includingSubchildren: Bool = false) {
        children.editEach({
            $0.isExpanded = true
            if includingSubchildren {
                $0.expandAll(includingSubchildren: true)
            }
        })
    }
    
    /**
      Collapses the current item and optionally collapses all subchildren as well.
      
      - Parameter includingSubchildren: A Boolean value indicating whether to collapse all subchildren. The default value is `false`.
      */
    mutating func collapseAll(includingSubchildren: Bool = false) {
        children.editEach({
            $0.isExpanded = false
            if includingSubchildren {
                $0.collapseAll(includingSubchildren: true)
            }
        })
    }
}
