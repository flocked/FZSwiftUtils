//
//  File.swift
//  
//
//  Created by Florian Zand on 26.05.23.
//

import Foundation

public extension MutableCollection {
    mutating func editEach(_ body: (inout Element) throws -> Void) rethrows {
        for index in self.indices {
            try body(&self[index])
        }
    }
}
