//
//  Array+.swift
//
//
//  Created by Florian Zand on 01.11.23.
//

import Foundation

public extension Array {
    /**
     Creates a new array containing the specified number of elements returned by a closure.
     
     Here’s an example of creating an array initialized with five random integers.
     
     ```swift
     let numbers = Array(generate: { Int.random(in: 0..<10) }, count: 5)
     print(numbers)
     // Prints "[4, 7, 3, 2, 7]"
     ```
     
     - Parameters:
        - generate: The closure that returns an element.
        - count: The number of times to repeat the closure's value passed in the `generate` parameter.
     */
    init(generate: ()->(Element), count: Int) {
        self = count >= 0 ? (0..<count).compactMap({ _ in generate() }) : []
    }
    
    /**
     Creates an array formed from `first` and repeated applications of `next`.
     
     The first element of the array is always `first`, and each successive element is the result of invoking `next` with the previous element. The array ends when next returns `nil`.
          
     - Parameters:
        - first: The first element of the array.
        - next: A closure that accepts the previous sequence element and returns the next element.
     */
    init(first: Element, next: @escaping (Element) -> Element?) {
        self = Array(sequence(first: first, next: next))
    }
}

public extension ArraySlice {
     /// The array slice as `Array`.
    var asArray: [Element] {
        Array(self)
    }
}

extension Array {
    /// A function builder type that produces an array.
    @resultBuilder
    public enum Builder {
        public typealias Component = [Element]

        public static func buildExpression(_ expression: Element?) -> Component {
            expression.map({ [$0] }) ?? []
        }

        public static func buildExpression(_ component: Component?) -> Component {
            component ?? []
        }

        public static func buildBlock(_ components: Component...) -> Component {
            components.flatMap { $0 }
        }

        public static func buildOptional(_ component: Component?) -> Component {
            component ?? []
        }

        public static func buildEither(first component: Component) -> Component {
            component
        }

        public static func buildEither(second component: Component) -> Component {
            component
        }

        public static func buildArray(_ components: [Component]) -> Component {
            components.flatMap { $0 }
        }

        public static func buildLimitedAvailability(_ component: Component) -> Component {
            component
        }

        public static func buildFinalResult(_ component: Component) -> [Element] {
            component
        }
    }

    public init(@Builder elements: () -> Self) {
        self = elements()
    }

    public mutating func append(@Builder elements: () -> Self) {
        append(contentsOf: elements())
    }

    public func appending(@Builder elements: () -> Self) -> Self {
        self + elements()
    }
}
