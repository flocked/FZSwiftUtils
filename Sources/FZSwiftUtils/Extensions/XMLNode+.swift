//
//  XMLNode+.swift
//
//
//  Created by Florian Zand on 30.04.25.
//

#if os(macOS)
import Foundation

extension XMLElement {
    /// Returns the attribute node with the specified name.
    public subscript (attribute name: String) -> XMLNode? {
        attribute(forName: name)
    }
}

extension XMLNode {
    /// Returns all element nodes among the children of the current node.
    var elements: [XMLNode] {
        children(forKind: .element)
    }

    /// Returns all text nodes among the children of the current node.
    var texts: [XMLNode] {
        children(forKind: .text)
    }
    
    /// Returns all comment nodes among the children of the current node.
    var comments: [XMLNode] {
        children(forKind: .comment)
    }
    
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
    
    /// Returns the content of the receiver as a URL value.
    public var urlValue: URL? {
        guard let stringValue = stringValue else { return nil }
        return URL(string: stringValue)
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
    
    /// A sequence of all descendant child nodes of a node.
    public struct ChildrenSequence: Sequence {
        private let node: XMLNode
        private let maxLevel: Int?
        private let _topChildrenFirst: Bool
        
        /// The maximum child level within the nodes tree hierarchy.
        public func maxLevel(_ maxLevel: Int) -> Self {
            Self(node, maxLevel, _topChildrenFirst)
        }
        
        func maxLevel(_ maxLevel: Int?) -> Self {
            Self(node, maxLevel, _topChildrenFirst)
        }
        
        /**
         Iterates the top-level children before their descendants.

         By default, the sequence performs a depth-first traversal where child nodes are visited before their siblings. Using this property changes the traversal order so that all direct children of the node are visited before their descendants.
         */
        public var topChildrenFirst: Self {
            Self(node, maxLevel, true)
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
            Iterator(node, maxLevel, _topChildrenFirst)
        }
        
        /// The iterator of a ``Foundation/XMLNode/ChildrenSequence``.
        public class Iterator: IteratorProtocol {
            private let node: XMLNode
            private let rootLevel: Int
            private let maxLevel: Int?
            private let topChildrenFirst: Bool
            
            private var index: Int = 0
            private var childIterator: Iterator? = nil
            private var firstRun = true
            
            /// The current child level.
            public private(set) var level: Int
            
            /// Skip recursion of the current child node.
            public func skipDescendants() {
                childIterator = nil
            }
            
            public func next() -> XMLNode? {
                topChildrenFirst ? nextTopChildrenFirst() : _next()
            }
            
            private func _next() -> XMLNode? {
                if let childIterator = childIterator, let node = childIterator.next() {
                    level = childIterator.level
                    return node
                }
                childIterator = nil
                guard index < node.childCount, let node = node.child(at: index) else { return nil }
                level = rootLevel
                index += 1
                if rootLevel+1 < maxLevel ?? .max {
                    childIterator = Iterator(node, maxLevel, topChildrenFirst, rootLevel+1)
                }
                return node
            }
            
            private func nextTopChildrenFirst() -> XMLNode? {
                if let childIterator = childIterator, let node = childIterator.next() {
                    level = childIterator.level
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
                    level = rootLevel
                    return node
                } else if rootLevel+1 < maxLevel ?? .max {
                    childIterator = Iterator(node, maxLevel, topChildrenFirst, rootLevel+1)
                    return nextTopChildrenFirst()
                }
                return nil
            }
            
            init(_ node: XMLNode, _ maxLevel: Int?, _ topChildrenFirst: Bool = false, _ level: Int = 0) {
                self.node = node
                self.level = level
                self.rootLevel = level
                self.maxLevel = maxLevel
                self.topChildrenFirst = topChildrenFirst
            }
        }
    }
    
    private var totalChildCount: Int {
        childCount + (children?.reduce(0) { $0 + $1.totalChildCount } ?? 0)
    }
}

extension XMLNode {
    /// Returns a sequence of all descendant attribute nodes.
    public var allAttributes: AttributeSequence {
        AttributeSequence(self)
    }
    
    /// A sequence of all descendant attribute nodes of a node.
    public struct AttributeSequence: Sequence {
        private let node: XMLNode
        private let maxLevel: Int?
        private let _byLevel: Bool
        
        /// The maximum child level within the nodes tree hierarchy.
        public func maxLevel(_ maxLevel: Int) -> Self {
            .init(node, maxLevel)
        }
        
        func maxLevel(_ maxLevel: Int?) -> Self {
            .init(node, maxLevel)
        }
        
        /**
         Iterates the attributes level by level.
         
         The default value is `false`, which iterates the attributes using a depth-first order.
         */
        public var byLevel: Self {
            .init(node, maxLevel, true)
        }
        
        init(_ node: XMLNode, _ maxLevel: Int? = nil, _ byLevel: Bool = false) {
            self.node = node
            self.maxLevel = maxLevel
            self._byLevel = byLevel
        }
        
        public func makeIterator() -> Iterator {
            Iterator(node, maxLevel, _byLevel, 0)
        }
        
        /// The iterator of a ``Foundation/XMLNode/AttributeSequence``.
        public class Iterator: IteratorProtocol {
            private let node: XMLNode
            private let rootLevel: Int
            private let maxLevel: Int?
            private let byLevel: Bool
            private var attributes: [XMLNode] = []
            
            private var index: Int = 0
            private var childIterator: Iterator? = nil
            
            private var queue: [(node: XMLNode, level: Int)] = []
            
            /// The current child level.
            public private(set) var level: Int
            
            /// Skip recursion of the current child node.
            public func skipDescendants() {
                childIterator = nil
            }
            
            public func next() -> XMLNode? {
                byLevel ? nextByLevel() : _next()
            }
            
            private func _next() -> XMLNode? {
                if let attribute = attributes.popLast() {
                    level = rootLevel
                    return attribute
                }
                if let childIterator = childIterator, let node = childIterator.next() {
                    level = childIterator.level
                    return node
                }
                childIterator = nil
                guard index < node.childCount, let node = node.child(at: index) else { return nil }
                index += 1
                if rootLevel+1 < maxLevel ?? .max {
                    childIterator = Iterator(node, maxLevel, byLevel, rootLevel+1)
                }
                return _next()
            }
            
            public func nextByLevel() -> XMLNode? {
                if let attribute = attributes.popLast() {
                    return attribute
                }
                while !queue.isEmpty {
                    let (currentNode, currentLevel) = queue.removeFirst()
                    self.level = currentLevel
                    if currentLevel + 1 < maxLevel ?? .max {
                        for child in (currentNode.children ?? []) {
                            queue.append((node: child, level: currentLevel + 1))
                        }
                    }
                    attributes = currentNode._attributes
                    if let attribute = attributes.popLast() {
                        return attribute
                    }
                }
                return nil
            }
            
            init(_ node: XMLNode, _ maxLevel: Int?, _ byLevel: Bool, _ level: Int) {
                self.node = node
                self.level = level
                self.rootLevel = level
                self.maxLevel = maxLevel
                self.byLevel = byLevel
                self.attributes = node._attributes
                self.queue.append((node: node, level: 0))
            }
        }
    }
    
    private var _attributes: [XMLNode] {
        ((self as? XMLElement)?.attributes ?? []).reversed()
    }
}
extension XMLNode.Kind: Swift.CustomStringConvertible {
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
#endif
