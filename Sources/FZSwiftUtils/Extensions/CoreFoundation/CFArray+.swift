//
//  CFArray+.swift
//
//
//  Created by Florian Zand on 05.12.25.
//

import Foundation

public extension CFArray {
    /// `NSArray` representation of the array.
    var nsArray: NSArray {
        self as NSArray
    }
}
