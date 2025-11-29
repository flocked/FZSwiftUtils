//
//  Sequence+Rotate.swift
//  
//
//  Created by Florian Zand on 04.07.25.
//

import Foundation

public extension Sequence {
    /**
     Returns an array of the sequence rotated by the specified amount of positions.
     
     Example:
     
     ```swift
     let values = [1, 2, 3, 4, 5]
     print(values.rotated(by: 1)) // [5, 1, 2, 3, 4]
     ```

     - Parameter positions: The amount of positions to rotate. A value larger than `0` rotates the collection to the right, a value smaller than `0` left.
     */
    func rotated(by positions: Int) -> [Element] {
        Array(self).rotated(by: positions)
    }

    /**
     Returns an array of the sequence rotated to start at the specified index.
     
     - Parameter index: The index of the element that should be at the start after rotating.
    */
    func rotated(toStartAt index: Int) -> [Element] {
        Array(self).rotated(toStartAt: index)
    }
}

public extension Collection {
    /**
     Returns the collection rotated by the specified amount of positions.
     
     Example:
     
     ```swift
     let values = [1, 2, 3, 4, 5]
     print(values.rotated(by: 1)) // [5, 1, 2, 3, 4]
     ```

     - Parameter positions: The amount of positions to rotate. A value larger than `0` rotates the collection to the right, a value smaller than `0` left.
     - Returns: The rotated collection.
     */
    func rotated(by positions: Int) -> [Element] {
        (self as? Array ?? Array(self)).rotated(by: positions)
    }

    /**
     Returns the collection rotated to start at the specified index.
     
     - Parameter index: The index of the element that should be at the start after rotating.
    */
    func rotated(toStartAt index: Int) -> [Element] {
        (self as? Array ?? Array(self)).rotated(toStartAt: index)
    }
}

public extension RangeReplaceableCollection {
    /**
     Returns the collection rotated by the specified amount of positions.
     
     Example:
     
     ```swift
     let values = [1, 2, 3, 4, 5]
     print(values.rotated(by: 1)) // [5, 1, 2, 3, 4]
     ```

     - Parameter positions: The amount of positions to rotate. A value larger than `0` rotates the collection to the right, a value smaller than `0` left.
     - Returns: The rotated collection.
     */
    func rotated(by positions: Int) -> Self {
        guard !isEmpty else { return self }
        let positions = positions.quotientAndRemainder(dividingBy: count).remainder
        guard positions != .zero else { return self }
        let index: Index
        if positions > 0 {
            index = self.index(endIndex, offsetBy: -positions, limitedBy: startIndex) ?? startIndex
        } else {
            index = self.index(startIndex, offsetBy: -positions, limitedBy: endIndex) ?? endIndex
        }
        return Self(self[index...] + self[..<index])
    }
    
    /**
     Returns the collection rotated to start at the specified index.
     
     - Parameter index: The index of the element that should be at the start after rotating.
    */
    func rotated(toStartAt index: Int) -> Self {
        guard index >= 0, index < endIndex else { return self }
        return rotated(by: -index)
    }

    /**
     Rotates the collection by the specified amount of positions.
     
     Example:
     
     ```swift
     var values = [1, 2, 3, 4, 5]
     values.rotate(by: 1)
     print(values) // [5, 1, 2, 3, 4]
     ```

     - Parameter positions: The amount of positions to rotate. A value larger than `0` rotates the collection to the right, a value smaller than `0` left.
     */
    mutating func rotate(by positions: Int) {
        self = rotated(by: positions)
    }
    
    /**
     Returns the collection rotated to start at the specified index.
     
     - Parameter index: The index of the element that should be at the start after rotating.
    */
    mutating func rotate(toStartAt index: Int) {
        guard index >= 0, index < endIndex else { return }
        rotate(by: -index)
    }
}
