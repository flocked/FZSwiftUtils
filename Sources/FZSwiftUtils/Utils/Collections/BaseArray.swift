//
//  ArrayBase.swift
//  Selectable
//
//  Created by Florian Zand on 15.10.21.
//


import Foundation

open class BaseArray<ElementType>: MutableCollection, RangeReplaceableCollection, RandomAccessCollection, BidirectionalCollection {

    internal var elements: [ElementType] = []
    
    required public init() {}
    
    required public init(arrayLiteral elements: ElementType...) {
        self.elements = elements
    }
    
    public var count: Int {
        return elements.count
    }
    
    public var underestimatedCount: Int {
        return elements.underestimatedCount
    }

    public func set(contents: [ElementType]) {
        elements = contents
    }
    
    public func removeAll() {
        elements.removeAll()
    }
    
    @discardableResult
    public func remove(at i: Int) -> ElementType {
        elements.remove(at: i)
    }
    
    @discardableResult
    public func removeFirst() -> ElementType {
        elements.removeFirst()
    }
    
    public func removeFirst(_ k: Int) {
        elements.removeFirst(k)
    }
    
    public func removeSubrange(_ bounds: Range<Int>) {
        elements.removeSubrange(bounds)
    }
    
    public func removeAll(where shouldBeRemoved: (ElementType) throws -> Bool) rethrows {
        try elements.removeAll(where: shouldBeRemoved)
    }
    
    public func removeAll(keepingCapacity keepCapacity: Bool) {
        elements.removeAll(keepingCapacity: keepCapacity)
    }
    
    public func removeLast(_ k: Int) {
        elements.removeLast(k)
    }
    
    public func removeLast() {
        elements.removeLast()
    }
    
    
    public func append(_ newElement: ElementType) {
        elements.append(newElement)
    }
    
    public func append<S>(contentsOf newElements: S) where S : Sequence, ElementType == S.Element {
        elements.append(contentsOf: newElements)
    }
    
    public var indices: Range<Int> {
        return elements.indices
    }
    
    public var isEmpty: Bool {
        return elements.isEmpty
    }
    
    public func distance(from start: Int, to end: Int) -> Int {
        return elements.distance(from: start, to: end)
    }
    
    public func swapAt(_ i: Int, _ j: Int) {
        elements.swapAt(i, j)
    }
    
    public func reserveCapacity(_ n: Int) {
        elements.reserveCapacity(n)
    }
    
    public func insert(_ newElement: ElementType, at i: Int) {
        self.elements.insert(newElement, at: i)
    }

    
    public func insert<S>(contentsOf newElements: S, at i: Int) where S : Collection, ElementType == S.Element {
        self.elements.insert(contentsOf: newElements, at: i)
    }
    
    public required init<S>(_ elements: S) where S : Sequence, ElementType == S.Element {
        self.elements = .init(elements)
    }
    
    public required init(repeating repeatedValue: ElementType, count: Int) {
        self.elements = .init(repeating: repeatedValue, count: count)

    }
    
    public func formIndex(after i: inout Int) {
        elements.formIndex(after: &i)
    }
    
    public func formIndex(before i: inout Int) {
        elements.formIndex(before: &i)
    }
    
    public func partition(by belongsInSecondPartition: (ElementType) throws -> Bool) rethrows -> Int {
        try elements.partition(by: belongsInSecondPartition)
    }
    
    public func withContiguousStorageIfAvailable<R>(_ body: (UnsafeBufferPointer<ElementType>) throws -> R) rethrows -> R? {
        try elements.withContiguousStorageIfAvailable(body)
    }
    
    public func withContiguousMutableStorageIfAvailable<R>(_ body: (inout UnsafeMutableBufferPointer<ElementType>) throws -> R) rethrows -> R? {
        try elements.withContiguousMutableStorageIfAvailable(body)
    }

    // Collection / Mutable Collection

    private func isInBounds(index: Int) -> Bool {
        return indices ~= index
    }

    public var startIndex: Int {
        return elements.startIndex
    }

    public var endIndex: Int {
        return elements.endIndex
    }

    public subscript(index: Int) -> ElementType {
        get {
            return elements[index]
        }
        set {
            elements[index] = newValue
        }
    }

    public func index(after i: Int) -> Int {
        return elements.index(after: i)
    }
    
    public func index(before i: Int) -> Int {
        return elements.index(before: i)
    }
    
    public func index(_ i: Int, offsetBy distance: Int) -> Int {
        return elements.index(i, offsetBy: distance)

    }
    
    public func index(_ i: Int, offsetBy distance: Int, limitedBy limit: Int) -> Int? {
        return elements.index(i, offsetBy: distance, limitedBy: limit)
    }

    public func replaceSubrange<C, R>(_ subrange: R, with newElements: C)
        where C: Collection, R: RangeExpression, ElementType == C.Element, Int == R.Bound {
            elements.replaceSubrange(subrange, with: newElements)
    }
}


// extension BaseArray: Sendable where Element: Sendable { }

extension BaseArray: Encodable where Element: Encodable { }

extension BaseArray: CVarArg {
    public var _cVarArgEncoding: [Int] {
        return elements._cVarArgEncoding
    }
}

extension BaseArray: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable  {
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
    public static func ==(lhs: BaseArray<ElementType>, rhs: BaseArray<ElementType>) -> Bool {
        return lhs.elements == rhs.elements
    }
}

extension BaseArray: ExpressibleByArrayLiteral {
    
}
