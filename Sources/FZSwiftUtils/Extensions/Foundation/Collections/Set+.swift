//
//  Set+Remove.swift
//  NewImageViewer
//
//  Created by Florian Zand on 15.09.22.
//

import Foundation

extension Set {
    mutating func remove<S: Sequence<Element>>(_ elements: S) {
        for element in elements {
            self.remove(element)
        }
    }
    mutating func insert<S: Sequence<Element>>(_ elements: S) {
        for element in elements {
            self.insert(element)
        }
    }
    
     func filter(where filter: ((Self.Element)->Bool)) -> Set<Self.Element> {
         var filteredElements = Set<Self.Element>()
         for element in self {
             if (filter(element) == true) {
                 filteredElements.insert(element)
             }
         }
         return filteredElements
    }
        
    mutating func removeAll(where remove: ((Self.Element)->Bool)) {
        self.remove(Array(self.filter(remove)))
    }
}
