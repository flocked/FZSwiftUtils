//
//  Sequence+Keypath.swift
//
//
//  Created by Florian Zand on 19.05.23.
//

import Foundation

public extension Sequence {
    /**
     Returns an array containing the results of mapping each value for the given element keypath.

     - Parameter keyPath: The keypath to the element.
     - Returns: An array containing the keypath elements of this sequence.
     */
    func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        map { $0[keyPath: keyPath] }
    }
    
    /**
     Returns an array containing the non-`nil` results of mapping each value for the given element keypath.

     - Parameter keyPath: The keypath to the element that can be optional.
     - Returns: An array of the non-`nil` results of the keypath elements.
     */
    func compactMap<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        compactMap { $0[keyPath: keyPath] }
    }
    
    /**
     Returns an array containing the non-`nil` results of mapping each non-`nil` value for the given element keypath.

     - Parameter keyPath: The keypath to the element that can be optional.
     - Returns: An array of the non-`nil` results of the keypath elements.
     */
    func compactMap<T>(_ keyPath: KeyPath<Element, T?>) -> [T] {
        compactMap { $0[keyPath: keyPath] }
    }

    /**
     Returns an array containing the concatenated results of mapping each sequence for the specified element keypath.

     Returns an array containing the non-`nil` results of mapping the given keypath element.

     - Parameter keyPath: The keypath to the sequence.
     - Returns: The resulting flattened array.
     */
    func flatMap<T, S: Sequence<T>>(_ keyPath: KeyPath<Element, S>) -> [T] {
        flatMap { $0[keyPath: keyPath] }
    }
    
    /**
     Returns an array containing the concatenated results of mapping each non-`nil` sequence for the specified element keypath.

     Returns an array containing the non-`nil` results of mapping the given keypath element.

     - Parameter keyPath: The keypath to the sequence.
     - Returns: The resulting flattened array.
     */
    func flatMap<T, S: Sequence<T>>(_ keyPath: KeyPath<Element, S?>) -> [T] {
        compactMap({ $0[keyPath: keyPath] }).flatMap({ $0 })
    }

    /**
     Returns an array containing, in order, the elements of the sequence that contain the keypath element.

     - Parameter keyPath: The keypath to the element.
     - Returns: An array containing, in order, the elements of the sequence that contain the keypath element.
     */
    func filter<T>(contains keyPath: KeyPath<Element, T?>) -> [Element] {
        filter { $0[keyPath: keyPath] != nil }
    }
    
    /**
     Returns an array containing, in order, the elements of the sequence that contain the keypath element.

     - Parameter keyPath: The keypath to the element.
     - Returns: An array containing, in order, the elements of the sequence that doesn't contain the keypath element.
     */
    func filter<T>(containsNot keyPath: KeyPath<Element, T?>) -> [Element] {
        filter { $0[keyPath: keyPath] == nil }
    }

    /**
     Returns a Boolean value indicating whether the sequence contains an element at the keypath.

     - Parameter keyPath: The keypath to the element.
     - Returns: true if the sequence contains an element at the keypath; otherwise, false.
     */
    func contains<T>(_ keyPath: KeyPath<Element, T?>) -> Bool {
        contains(where: { $0[keyPath: keyPath] != nil })
    }

    /**
     Returns the first element of the sequence at a keypath.

     - Parameter keyPath: The keypath to the element.
     - Returns: The first element of the sequence at the keypath.
     */
    func first<T>(_ keyPath: KeyPath<Element, T?>) -> T? {
        first(where: { $0[keyPath: keyPath] != nil })?[keyPath: keyPath]
    }

    /**
     The number of elements at a keypath.

     - Parameter keyPath: The keypath to the element.
     - Returns: The number of elements of the sequence at the keypath.
     */
    func count<T>(of keyPath: KeyPath<Element, T?>) -> Int {
        filter { $0[keyPath: keyPath] != nil }.count
    }
    
    /**
     - Maps the specified values to the property at the specified key path.

     - Parameters:
        - values: Values to map to the property.
        - keyPath: The keypath to the property.
     */
    func map<T, S: Sequence<T>>(_ values: S, to keyPath: ReferenceWritableKeyPath<Element, T>) {
        zip(self, values).forEach({
            $0.0[keyPath: keyPath] = $0.1
        })
    }
}

public extension BidirectionalCollection {
    /**
     Returns the last element of the sequence at a keypath.

     - Parameter keyPath: The keypath to the element.
     - Returns: The last element of the sequence at the keypath.
     */
    func last<T>(_ keyPath: KeyPath<Element, T?>) -> T? {
        last(where: { $0[keyPath: keyPath] != nil })?[keyPath: keyPath]
    }
}

public extension Collection {
    /**
     The indexes of an element at a keypath.

     - Parameter keyPath: The keypath to the element.
     - Returns: The indexes of the element at the keypath.
     */
    func indexes<T>(of keyPath: KeyPath<Element, T?>) -> [Index] {
        indexes(where: { $0[keyPath: keyPath] != nil })
    }
}

public extension RangeReplaceableCollection {
    /**
     Removes all elements that have a value for the specified optional property.

     - Parameter keypath: The keypath to the optional property.
     */
    mutating func removeAll<Value>(with keypath: KeyPath<Element, Value?>) {
        removeAll(where: { $0[keyPath: keypath] != nil })
    }
    
    /**
     Removes all elements without a value for the specified optional property.

     - Parameter keypath: The keypath to the optional property.
     */
    mutating func removeAll<Value>(without keypath: KeyPath<Element, Value?>) {
        removeAll(where: { $0[keyPath: keypath] == nil })        
    }
}
