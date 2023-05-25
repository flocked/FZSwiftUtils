//
//  OutlineItem.swift
//  OutlineItem
//
//  Created by Florian Zand on 06.11.21.
//

import Foundation

public protocol OutlineItem {
    associatedtype ItemType
    var isExpandable: Bool { get }
    var children: [ItemType] { get }
}

public extension OutlineItem {
    var isExpandable: Bool {
        return (children.isEmpty == false)
    }
}
