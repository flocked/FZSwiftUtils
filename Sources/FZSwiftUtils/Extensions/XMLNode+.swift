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
        children(forName: name)
    }
    
    /// Returns the child nodes that have the specified kind.
    public subscript (kind: Kind) -> [XMLNode] {
        children(forKind: kind)
    }
    
    /// Returns the child nodes that have the specified name and kind.
    @_disfavoredOverload
    public subscript (name: String, kind: Kind) -> [XMLNode] {
        children(forName: name, kind: kind)
    }
    
    /// Returns the child node at the specified location.
    public subscript (index: Int) -> XMLNode? {
        child(at: index)
    }
    
    /// Returns the child nodes that have the specified name.
    func children(forName name: String) -> [XMLNode] {
        return children?.filter { $0.name == name } ?? []
    }
    
    /// Returns the child nodes that have the specified kind.
    func children(forKind kind: Kind) -> [XMLNode] {
        return children?.filter { $0.kind == kind } ?? []
    }
    
    /// Returns the child nodes that have the specified name and kind.
    func children(forName name: String, kind: Kind) -> [XMLNode] {
        return children?.filter { $0.name == name && $0.kind == kind } ?? []
    }
}
