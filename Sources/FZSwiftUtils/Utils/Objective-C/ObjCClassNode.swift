//
//  ObjCClassNode.swift
//
//
//  Created by Florian Zand on 06.03.26.
//

import Foundation

/// An Objective-C class node.
public final class ObjCClassNode {
    /// The class of the node.
    public var `class`: AnyClass { _cls.cls }
    
    /// The information about the class of the node.
    public var info: ObjCClassInfo { _cls.info }
    
    /// The subclasses of the class of the node.
    public var subclasses: [ObjCClassNode] = []
    
    private let _cls: SearchClass
    
    private init(cls: SearchClass, subclasses: [ObjCClassNode] = []) {
        self._cls = cls
        self.subclasses = subclasses
    }
    
    func node(containing search: String?) -> ObjCClassNode? {
        guard let search = search?.lowercased(), !search.isEmpty else { return self }
        let subclasses = subclasses(containing: search)
        guard !subclasses.isEmpty else { return nil }
        return ObjCClassNode(cls: _cls, subclasses: subclasses)
    }
    
    public func subclasses(containing search: String) -> [ObjCClassNode] {
        guard !search.isEmpty else { return self.subclasses }
        return subclasses.compactMap { $0.filteredNode(search) }
    }
    
    private func filteredNode(_ search: String) -> ObjCClassNode? {
        let filteredChildren = subclasses.compactMap { $0.filteredNode(search) }
        if _cls.containsSearchString(search) || !filteredChildren.isEmpty {
            let node = ObjCClassNode(cls: _cls)
            node.subclasses = filteredChildren
            return node
        }
        return nil
    }
    
    private func sort() {
        subclasses.sort(by: \._cls.info.name)
        subclasses.forEach({$0.sort()})
    }
    
    static func rootNodes(for classes: [SearchClass]) -> [ObjCClassNode] {
        var nodesByClass: [ObjectIdentifier: ObjCClassNode] = [:]
        nodesByClass.reserveCapacity(classes.count)
        for info in classes {
            nodesByClass[info.id] = ObjCClassNode(cls: info)
        }
        var roots: [ObjCClassNode] = []
        roots.reserveCapacity(classes.count)
        for cls in classes {
            guard let node = nodesByClass[cls.id] else { continue }
            if let superClass = cls.info._superclass, let parent = nodesByClass[superClass] {
                parent.subclasses.append(node)
            } else {
                roots.append(node)
            }
        }
        roots.forEach({ $0.sort()} )
        return roots
    }
}

struct SearchClass {
    public let info: ObjCClassInfo
    let cls: AnyClass
    let id: ObjectIdentifier
    let names: [String]
    
    public func containsSearchString(_ search: String) -> Bool {
        names.contains(where: {$0.contains(search) })
    }
    
    init(_ class: AnyClass) {
        self.info = ObjCClassInfo(`class`)
        self.cls = `class`
        self.id = ObjectIdentifier(`class`)
        var names = [info.name.lowercased()]
        names += (info.properties + info.classProperties).map({$0.name.lowercased()})
        names += (info.methods + info.classMethods).map({$0.name.lowercased()})
        names += info.ivars.map({$0.name.lowercased()})
        names += info.protocols.map({$0.name.lowercased()})
        self.names = names
    }
}
