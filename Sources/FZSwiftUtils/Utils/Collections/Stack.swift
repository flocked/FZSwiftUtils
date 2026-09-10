//
//  Stack.swift
//
//
//  Created by Florian Zand on 09.03.25.
//

import Foundation

/**
 A stack data structure that follows the Last-In-First-Out (LIFO) principle.

 The `Stack` allows elements to be added (`push`) to the top, removed (`pop`) from the top, and inspected (`current`) without removing them. It also provides properties to check whether the stack is empty or to retrieve the number of elements currently in the stack.
 */
public struct Stack<Element> {
    private var elements: [Element] = []
    
    /// A Boolean value indicating whether the stack is empty.
    public var isEmpty: Bool {
        elements.isEmpty
    }
    
    /// The number of elements in the stack.
    public var count: Int {
        elements.count
    }
    
    /**
     Returns the top element of the stack.

     - Returns: The top element of the stack, or `nil` if the stack is empty.
     */
    public var current: Element? {
        elements.last
    }
    
    /// Pushes the specified element onto the top of the stack.
    public mutating func push(_ element: Element) {
        elements.append(element)
    }
    
    /**
     Removes and returns the top element of the stack.

     - Returns: The top element of the stack, or `nil` if the stack is empty.
     */
    @discardableResult
    public mutating func pop() -> Element? {
        elements.popLast()
    }
}

extension Stack: _ObjectiveCBridgeable {
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
