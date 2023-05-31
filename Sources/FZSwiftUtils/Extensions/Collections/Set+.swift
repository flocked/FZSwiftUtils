//
//  Set+Remove.swift
//  NewImageViewer
//
//  Created by Florian Zand on 15.09.22.
//

import Foundation

extension Set {
    mutating func remove<S: Sequence<Element>>(_ elements: S) {
        elements.forEach({ self.remove($0) })
    }

    mutating func insert<S: Sequence<Element>>(_ elements: S) {
        elements.forEach({ self.insert($0) })
    }

    func filter(where filter: (Self.Element) -> Bool) -> Set<Self.Element> {
        return Set( self.filter({filter($0)}) )
    }
    
    mutating func removeAll<Value>(containing keypath: KeyPath<Element, Value>) {
       // filter(keypath)
    }

    mutating func removeAll(where remove: (Self.Element) -> Bool) {
        self.remove(Array(filter(remove)))
    }
}
