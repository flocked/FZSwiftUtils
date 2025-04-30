//
//  XMLNode+.swift
//
//
//  Created by Florian Zand on 30.04.25.
//

import Foundation

extension XMLElement {
    /// Returns the attribute node with the specified name.
    public subscript (attribute name: String) -> XMLNode? {
        attribute(forName: name)
    }
}

extension XMLNode {
    /// Returns the child nodes that have the specified name.
    public subscript (name: String) -> [XMLNode] {
        children(named: name)
    }
    
    /// Returns the child nodes that have the specified kind.
    public subscript (kind: Kind) -> [XMLNode] {
        children(forKind: kind)
    }
    
    /// Returns the child nodes that have the specified name and kind.
    public subscript (name: String, kind: Kind) -> [XMLNode] {
        children(named: name, kind: kind)
    }
    
    /// Returns all descendant child nodes that have the specified name.
    public subscript (all name: String?, maxLevel: Int? = nil) -> [XMLNode] {
        allChildren.maxLevel(maxLevel).filter({ $0.name == name }).collect()
    }
    
    /// Returns all descendant child nodes that have the specified kind.
    public subscript (all kind: Kind, maxLevel: Int? = nil) -> [XMLNode] {
        allChildren.maxLevel(maxLevel).filter({ $0.kind == kind }).collect()
    }
    
    /// Returns all descendant child nodes that have the specified name and kind.
    public subscript (all name: String?, kind: Kind, maxLevel: Int? = nil) -> [XMLNode] {
        allChildren.maxLevel(maxLevel).filter({ $0.kind == kind && $0.name == name }).collect()
    }
    
    /// Returns all descendant attribute nodes that have the specified name.
    public subscript (allAttributes name: String, maxLevel: Int? = nil) -> [XMLNode] {
        allChildren.maxLevel(maxLevel).compactMap({ ($0 as? XMLElement)?.attribute(forName: name) }).collect()
    }
    
    /// Returns the child node at the specified location.
    public subscript (index: Int) -> XMLNode? {
        child(at: index)
    }
    
    /// Returns the child nodes that have the specified name.
    public func children(named name: String) -> [XMLNode] {
        children?.filter { $0.name == name } ?? []
    }
    
    /// Returns the child nodes that have the specified kind.
    public func children(forKind kind: Kind) -> [XMLNode] {
        children?.filter { $0.kind == kind } ?? []
    }
    
    /// Returns the child nodes that have the specified name and kind.
    public func children(named name: String, kind: Kind) -> [XMLNode] {
        children?.filter { $0.name == name && $0.kind == kind } ?? []
    }
    
    /// Returns the content of the receiver as a integer value.
    public var integerValue: Int? {
        guard let stringValue = stringValue else { return nil }
        return Int(stringValue)
    }
    
    /// Returns the content of the receiver as a double value.
    public var doubleValue: Double? {
        guard let stringValue = stringValue else { return nil }
        return Double(stringValue)
    }
    
    /// Returns the content of the receiver as a boolean value.
    public var boolValue: Bool? {
        guard let stringValue = stringValue else { return nil }
        return Bool(stringValue)
    }
    
    /**
     Returns a string that represents the kind of the node and it's children.
     
     For example:
     ```
     document
       element: URL [link]
       element: URL [link]
       element: Image [link, width, height]
       element: Parent [name, age]
         element: Child
           text
       element: Parent [name, age]
         element: Child
           text
     ```
          
     - Parameters:
        - includeAttributes: A Boolean value indiciating whether to include the attribute names for each node.
        - maxLevel: The maximum nesting level within the nodes tree hierarchy.
        - maxCount: The maximum amount of children per node, or `nil` to include all.

     */
    public func xmlKindString(includeAttributes: Bool = true, maxLevel: Int? = nil, maxCount: Int? = nil) -> String {
        xmlKindString(at: 0, includeAttributes: includeAttributes, maxLevel: maxLevel, maxCount: maxCount)
    }
    
    private func xmlKindString(at level: Int, includeAttributes: Bool, maxLevel: Int?, maxCount: Int?) -> String {
        var lines: [String] = []
        var attributes = ""
        if includeAttributes, let attrs = (self as? Foundation.XMLElement)?.attributes?.compactMap({ $0.name }), !attrs.isEmpty {
            attributes = "[\(attrs.joined(separator: ", "))]"
        }
        if let name = name {
            lines += "\(String(repeating: " ", count: level))\(kind): \(name) \(attributes)"
        } else {
            lines += "\(String(repeating: " ", count: level))\(kind) \(attributes)"
        }
        
        if level+1 < maxLevel ?? .max {
            let children = children?[safe: 0..<(maxCount ?? childCount).clamped(max: childCount)] ?? []
            lines += children.map({ $0.xmlKindString(at: level+1, includeAttributes: includeAttributes, maxLevel: maxLevel, maxCount: maxCount) })
        }
        return lines.joined(separator: "\n")
    }
}

extension XMLNode {
    /// Returns a sequence of all descendant child nodes.
    public var allChildren: ChildrenSequence {
        ChildrenSequence(self)
    }
    
    /// A sequnce of all descendant child nodes of a node.
    public struct ChildrenSequence: Sequence {
        private let node: XMLNode
        private let maxLevel: Int?
        private let _topChildrenFirst: Bool
        
        /// The maximum child level within the nodes tree hierarchy.
        public func maxLevel(_ maxLevel: Int) -> Self {
            .init(node, maxLevel)
        }
        
        func maxLevel(_ maxLevel: Int?) -> Self {
            .init(node, maxLevel)
        }
        

        /**
         Iterates the top-level children before their descendants.

         By default, the sequence performs a depth-first traversal where child nodes are visited before their siblings. Using this property changes the traversal order so that all direct children of the node are visited before their descendants.
         */
        public var topChildrenFirst: Self {
            .init(node, maxLevel, true)
        }
        
        /// The number of children in the sequence.
        public var count: Int {
            node.totalChildCount
        }
        
        init(_ node: XMLNode, _ maxLevel: Int? = nil, _ topChildrenFirst: Bool = false) {
            self.node = node
            self.maxLevel = maxLevel
            self._topChildrenFirst = topChildrenFirst
        }
        
        public func makeIterator() -> Iterator {
            Iterator(node, maxLevel, 0, _topChildrenFirst)
        }
        
        public class Iterator: IteratorProtocol {
            private let node: XMLNode
            private let maxLevel: Int?
            private var topChildrenFirst: Bool
            
            private var index: Int = 0
            private var childIterator: Iterator? = nil
            private var firstRun = true
            
            /// The current child level.
            public let level: Int
            
            public func next() -> XMLNode? {
                topChildrenFirst ? _nexttopChildrenFirst : _next
            }
            
            private var _next: XMLNode? {
                if let node = childIterator?.next() {
                    return node
                }
                childIterator = nil
                guard index < node.childCount, let node = node.child(at: index) else { return nil }
                index += 1
                if level+1 < maxLevel ?? .max {
                    childIterator = Iterator(node, maxLevel, level+1, topChildrenFirst)
                }
                return node
            }
            
            private var _nexttopChildrenFirst: XMLNode? {
                if let node = childIterator?.next() {
                    return node
                }
                childIterator = nil
                if index == node.childCount-1, firstRun {
                    index = 0
                    firstRun = false
                }
                guard index < node.childCount, let node = node.child(at: index) else { return nil }
                index += 1
                if firstRun {
                    return node
                } else if level+1 < maxLevel ?? .max {
                    childIterator = Iterator(node, maxLevel, level+1, topChildrenFirst)
                }
                return childIterator?.next()
            }
            
            init(_ node: XMLNode, _ maxLevel: Int?, _ level: Int = 0, _ topChildrenFirst: Bool = false) {
                self.node = node
                self.maxLevel = maxLevel
                self.level = level
                self.topChildrenFirst = topChildrenFirst
            }
        }
    }
    
    private var totalChildCount: Int {
        childCount + (children?.reduce(0) { $0 + $1.totalChildCount } ?? 0)
    }
}

extension XMLNode.Kind: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalid: return "invalid"
        case .document: return "document"
        case .element: return "element"
        case .attribute: return "attribute"
        case .namespace: return "namespace"
        case .processingInstruction: return "processingInstruction"
        case .comment: return "comment"
        case .text: return "text"
        case .DTDKind: return "DTDKind"
        case .entityDeclaration: return "entityDeclaration"
        case .attributeDeclaration: return "attributeDeclaration"
        case .elementDeclaration: return "elementDeclaration"
        case .notationDeclaration: return "notationDeclaration"
        default: return "unknown"
        }
    }
}
