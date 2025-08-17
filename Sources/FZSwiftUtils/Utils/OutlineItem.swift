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

/// An outline item.
open class ElementOutlineItem<Element>: Hashable, CustomStringConvertible, CustomDebugStringConvertible {
    private let id = UUID()

    /// The value of the item.
    open var element: Element
    
    /// The parent of the item.
    open private(set) weak var parent: ElementOutlineItem<Element>? {
        didSet { updateIndexPathRecursively() }
    }
    
    /// The child items of the item.
    open var children: [ElementOutlineItem<Element>] = [] {
        didSet {
            guard oldValue != children else { return }
            let diff = oldValue.difference(to: children)
            diff.removed.forEach { $0.parent = nil }
            diff.added.forEach { item in
                item.parent?.removeChild(item)
                item.parent = self
            }
        }
    }
    
    /// The index path of the item.
    open private(set) var indexPath = IndexPath()
    
    /// A Boolean value indicating whether the item is expanded.
    open var isExpanded = false
    
    /// A Boolean value indicating whether the item is expandable.
    open var isExpandable = true

    /**
     Expands the item.
     
     The item is expanded, if ``isExpandable`` is `true`.
     
     - Parameters:
        - exclusive: A Boolean value indicating whether the item should be expanded exclusive
        - expandChildren: A Boolean value indicating whether the children should be expanded.
     */
    open func expand(exclusive: Bool = false, expandChildren: Bool = false) {
        guard isExpandable else { return }
        isExpanded = true
        if expandChildren {
            children.forEach({ $0.expand() })
        }
        guard exclusive else { return }
        parent?.children.filter({ $0.id != id }).forEach({ $0.collapse() })
    }
    
    /**
     Collapses the item.
     
     The item is collapsed, if ``isExpandable`` is `true`.
     
     - Parameter collapseChildren: A Boolean value indicating whether the children should be collapsed.
     */
    open func collapse(collapseChildren: Bool = false) {
        guard isExpandable else { return }
        isExpanded = false
        if collapseChildren {
            children.forEach({ $0.collapse() })
        }
    }
    
    /**
     Expands all children of the item.
     
     - Parameter includingSubchildren: A Boolean value indicating whether the children of each child should also be expanded.
     */
    open func expandChildren(includingSubchildren: Bool = false) {
        children.forEach({ $0.expand(expandChildren: includingSubchildren) })
    }
    
    /**
     Collapses all children of the item.
     
     - Parameter includingSubchildren: A Boolean value indicating whether the children of each child should also be collapsed.
     */
    open func collapseChildren(includingSubchildren: Bool = false) {
        children.forEach({ $0.collapse(collapseChildren: includingSubchildren) })
    }
    
    /// A Boolean value indicating whether the item is a children of the specified item.
    open func isChild(of parent: ElementOutlineItem<Element>) -> Bool {
        var current = self.parent
        while let p = current {
            if p === parent { return true }
            current = p.parent
        }
        return false
    }
    
    /// A Boolean value indicating whether the item is the parent of the specified item.
    open func isParent(of child: ElementOutlineItem<Element>) -> Bool {
        child.isChild(of: self)
    }
    
    /// A Boolean value indicating whether the item contains the specified item as child.
    open func containsChild(_ child: ElementOutlineItem<Element>) -> Bool {
        children.contains(where: { $0.id == child.id }) || children.contains(where: { $0.containsChild(child) })
    }
    
    /// Returns the child items matching the specified predicate.
    open func filter(_ insIncluded: (ElementOutlineItem<Element>) throws -> Bool) rethrows -> [ElementOutlineItem<Element>] {
        try children.compactMap { try $0.filterChildren(insIncluded) }
    }
    
    /// Returns the child items matching the specified predicate.
    open func filter(_ insIncluded: (Element) throws -> Bool) rethrows -> [ElementOutlineItem<Element>] {
        try children.compactMap { try $0.filterChildren(insIncluded) }
    }
    
    private func filterChildren(_ insIncluded: (ElementOutlineItem<Element>) throws -> Bool) rethrows -> ElementOutlineItem<Element>? {
        let filteredChildren = try children.compactMap { try $0.filterChildren(insIncluded) }
        if try insIncluded(self) || !filteredChildren.isEmpty {
            let copy = ElementOutlineItem(element: element)
            copy.children = filteredChildren
            return copy
        } else {
            return nil
        }
    }
    
    private func filterChildren(_ insIncluded: (Element) throws -> Bool) rethrows -> ElementOutlineItem<Element>? {
        try filterChildren { try insIncluded($0.element) }
    }
    
    private func removeChild(_ child: ElementOutlineItem<Element>) {
        guard let index = children.firstIndex(where: { $0.id == child.id }) else { return }
        children.remove(at: index)
    }
    
    /// Creates an outline item with the specified value.
    public init(element: Element, children: [ElementOutlineItem<Element>] = []) {
        self.element = element
        defer { self.children = children }
    }
    
    /// Creates an outline item with the specified value.
    public init(_ element: Element, children: [ElementOutlineItem<Element>] = []) {
        self.element = element
        defer { self.children = children }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: ElementOutlineItem<Element>, rhs: ElementOutlineItem<Element>) -> Bool {
        lhs.id == rhs.id
    }
    
    public var description: String {
        string()
    }
    
    public var debugDescription: String {
        string(includeParent: true)
    }
    
    private func string(level: Int = 0, depth: Int = .max, maxChildren: Int? = nil, includeParent: Bool = false) -> String {
        var strings: [String] = []
        var string = "\(element)"
        if includeParent {
            if let parent = parent {
                string = "(\(string), parent: \(parent.element))"
            } else {
                string = "(\(string), parent: -)"
            }
        }
        strings = [Array(repeating: " ", count: level).joined(separator: "") + string]
        if level+1 <= depth {
            if let maxChildren = maxChildren {
                strings += children[safe: 0..<maxChildren].map({ $0.string(level: level+1, depth: depth, maxChildren: maxChildren) })
            } else {
                strings += children.map({ $0.string(level: level+1, depth: depth, maxChildren: maxChildren) })
            }
        }
        return strings.joined(separator: "\n")
    }
    
    private func updateIndexPathRecursively() {
        if let parent = parent, let index = parent.children.firstIndex(where: { $0 === self }) {
            indexPath = parent.indexPath.appending(index)
        } else {
            indexPath = IndexPath()
        }
        children.forEach { $0.updateIndexPathRecursively() }
    }
}
