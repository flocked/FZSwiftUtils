//
//  XMLNode+.swift
//
//
//  Created by Florian Zand on 30.04.25.
//

import Foundation

extension XMLElement {
    /// Returns the child nodes that have the specified name.
    public subscript (name: String) -> [XMLElement] {
        elements(forName: name)
    }
    
    /// Returns the child nodes that have the specified name and kind.
    public subscript (name: String, kind: Kind) -> [XMLElement] {
        elements(forName: name).filter({$0.kind == kind })
    }
    
    /// Returns the attribute node with the specified name.
    public subscript (attribute name: String) -> XMLNode? {
        attribute(forName: name)
    }
}

extension XMLNode {
    /// Returns the child nodes that have the specified name.
    @_disfavoredOverload
    public subscript (name: String) -> [XMLNode] {
        children(named: name)
    }
    
    /// Returns the child nodes that have the specified kind.
    public subscript (kind: Kind) -> [XMLNode] {
        children(forKind: kind)
    }
    
    /// Returns the child nodes that have the specified name and kind.
    @_disfavoredOverload
    public subscript (name: String, kind: Kind) -> [XMLNode] {
        children(named: name, kind: kind)
    }
    
    /// Returns the child node at the specified location.
    public subscript (index: Int) -> XMLNode? {
        child(at: index)
    }
    
    /// Returns the child nodes that have the specified name.
    func children(named name: String) -> [XMLNode] {
        children?.filter { $0.name == name } ?? []
    }
    
    /// Returns the child nodes that have the specified kind.
    func children(forKind kind: Kind) -> [XMLNode] {
        children?.filter { $0.kind == kind } ?? []
    }
    
    /// Returns the child nodes that have the specified name and kind.
    func children(named name: String, kind: Kind) -> [XMLNode] {
        children?.filter { $0.name == name && $0.kind == kind } ?? []
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

/*
extension XMLNode: Sequence {
    public func makeIterator() -> Iterator {
        Iterator(self)
    }
    
    public struct Iterator: IteratorProtocol {
        let node: XMLNode
        var index: Int = 0
        
        mutating public func next() -> XMLNode? {
            guard let node = node.child(at: index) else { return nil }
            index += 1
            return node
        }
        
        init(_ node: XMLNode) {
            self.node = node
        }
    }
    
}
*/
