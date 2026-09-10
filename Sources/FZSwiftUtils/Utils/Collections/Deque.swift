//
//  Deque.swift
//
//
//  Created by Florian Zand on 09.03.25.
//

import Foundation

/**
 A double-ended queue (Deque) allows elements to be added or removed from both ends (front and back).

 The `Deque` provides efficient access to both ends of the queue for insertion and removal.
 */
public struct Deque<Element> {
    private var elements: [Element] = []

    /// A Boolean value indicating whether the deque is empty.
    public var isEmpty: Bool {
        return elements.isEmpty
    }

    /// The number of elements in the deque.
    public var count: Int {
        return elements.count
    }

    /**
     Adds an element to the front of the deque.

     - Parameter element: The element to add to the front of the deque.
     */
    public mutating func pushFront(_ element: Element) {
        elements.insert(element, at: 0)
    }

    /**
     Adds an element to the back of the deque.

     - Parameter element: The element to add to the back of the deque.
     */
    public mutating func pushBack(_ element: Element) {
        elements.append(element)
    }

    /**
     Removes and returns the first element of the deque.

     - Returns: The first element of the deque, or `nil` if the deque is empty.
     */
    @discardableResult
    public mutating func popFront() -> Element? {
        return isEmpty ? nil : elements.removeFirst()
    }

    /**
     Removes and returns the last element of the deque.

     - Returns: The last element of the deque, or `nil` if the deque is empty.
     */
    @discardableResult
    public mutating func popBack() -> Element? {
        return isEmpty ? nil : elements.removeLast()
    }

    /**
     The first element of the deque.

     - Returns: The first element of the deque, or `nil` if the deque is empty.
     */
    public func peekFront() -> Element? {
        return elements.first
    }

    /**
     The last element of the deque.

     - Returns: The last element of the deque, or `nil` if the deque is empty.
     */
    public func peekBack() -> Element? {
        return elements.last
    }
}

extension Deque: _ObjectiveCBridgeable {
    public func _bridgeToObjectiveC() -> NSArray {
        elements._bridgeToObjectiveC()
    }

    public static func _forceBridgeFromObjectiveC(_ source: NSArray, result: inout Self?) {
        var elements: [Element]?
        [Element]._forceBridgeFromObjectiveC(source, result: &elements)
        result = elements.map { .init(elements: $0) }
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: NSArray, result: inout Self?) -> Bool {
        var elements: [Element]?
        guard [Element]._conditionallyBridgeFromObjectiveC(source, result: &elements),
              let elements else {
            result = nil
            return false
        }

        result = .init(elements: elements)
        return true
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: NSArray?) -> Self {
        .init(elements: [Element]._unconditionallyBridgeFromObjectiveC(source))
    }
}
