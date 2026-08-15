//
//  Array+.swift
//
//
//  Created by Florian Zand on 01.11.23.
//

import Foundation

public extension Array where Element: Collection, Element.Index == Int {
    subscript(indexPath: IndexPath) -> Element.Element {
        self[indexPath.section][indexPath.item]
    }

    subscript(safe indexPath: IndexPath) -> Element.Element? {
        self[safe: indexPath.section]?[safe: indexPath.item]
    }
    
    subscript(indexPath: IndexPath) -> Element.Element where Element: MutableCollection {
        get { self[indexPath.section][indexPath.item] }
        set { self[indexPath.section][indexPath.item] = newValue }
    }
    
    subscript(safe indexPath: IndexPath) -> Element.Element? where Element: MutableCollection {
        get { self[safe: indexPath.section]?[safe: indexPath.item] }
        set {
            guard let newValue else { return }
            self[safe: indexPath.section]?[safe: indexPath.item] = newValue
        }
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
