//
//  Queue.swift
//
//
//  Created by Florian Zand on 09.03.25.
//

import Foundation

/**
 A queue data structure that follows the First-In-First-Out (FIFO) principle.

 The `Queue` allows elements to be added (`enqueue`) to the back, removed (`dequeue`) from the front, and inspected (`peek`) without removing them.
 */
public struct Queue<Element> {
    private var elements: [Element] = []

    /// A Boolean value indicating whether the queue is empty.
    public var isEmpty: Bool {
        return elements.isEmpty
    }

    /// The number of elements in the queue.
    public var count: Int {
        return elements.count
    }

    /// Adds the specified element to the back of the queue.
    public mutating func enqueue(_ element: Element) {
        elements.append(element)
    }

    /// Removes and returns the front element of the queue.
    @discardableResult
    public mutating func dequeue() -> Element? {
        return isEmpty ? nil : elements.removeFirst()
    }

    /**
     The current front element of the queue.

     - Returns: The front element of the queue, or `nil` if the queue is empty.
     */
    public var current: Element? {
        return elements.first
    }
}
