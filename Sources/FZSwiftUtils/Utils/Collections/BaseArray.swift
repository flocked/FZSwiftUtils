//
//  ArrayBase.swift
//  
//
//  Created by Florian Zand on 15.10.21.
//

import Foundation

public struct BaseArray<Element>: MutableCollection, RangeReplaceableCollection, RandomAccessCollection, BidirectionalCollection {
    var elements: [Element] = []

    public init() { }

    public init(arrayLiteral elements: Element...) {
        self.elements = elements
    }

    public init<S>(_ elements: S) where S: Sequence, Element == S.Element {
        self.elements = .init(elements)
    }

    public init(repeating repeatedValue: Element, count: Int) {
        elements = .init(repeating: repeatedValue, count: count)
    }

    public var count: Int {
        return elements.count
    }

    public var isEmpty: Bool {
        return elements.isEmpty
    }

    public var startIndex: Int {
        return elements.startIndex
    }

    public var endIndex: Int {
        return elements.endIndex
    }

    public subscript(index: Int) -> Element {
        get {  return elements[index] }
        set {  elements[index] = newValue }
    }

    public mutating func replaceSubrange<C, R>(_ subrange: R, with newElements: C)
        where C: Collection, R: RangeExpression, Element == C.Element, Int == R.Bound {
        elements.replaceSubrange(subrange, with: newElements)
    }
}

extension BaseArray: ExpressibleByArrayLiteral { }
extension BaseArray: Sendable where Element: Sendable { }
extension BaseArray: Encodable where Element: Encodable {}
extension BaseArray: Decodable where Element: Decodable {}

extension BaseArray: CVarArg {
    public var _cVarArgEncoding: [Int] {
        return elements._cVarArgEncoding
    }
}

extension BaseArray: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    public var customMirror: Mirror {
        return elements.customMirror
    }

    public var debugDescription: String {
        return elements.debugDescription
    }

    public var description: String {
        return elements.description
    }
}

extension BaseArray: Hashable where Element: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(elements)
    }
}

extension BaseArray: ContiguousBytes {
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        try elements.withUnsafeBytes(body)
    }
}

extension BaseArray: Equatable where Element: Equatable {
    public static func == (lhs: BaseArray<Element>, rhs: BaseArray<Element>) -> Bool {
        return lhs.elements == rhs.elements
    }
}
