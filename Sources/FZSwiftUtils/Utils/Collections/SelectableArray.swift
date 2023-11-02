//
//  SelectableArray.swift
//
//
//  Created by Florian Zand on 15.10.21.
//

import Foundation
public protocol ABC {}
public typealias Vecttt = SelectableArray<ABC>

public struct SelectableArray<Element>: MutableCollection, RangeReplaceableCollection, RandomAccessCollection, BidirectionalCollection {
    internal var elements: [Element] = []

    public init() {}

    public init(arrayLiteral elements: Element...) {
        self.elements = elements
    }

    public var count: Int {
        return elements.count
    }

    public var underestimatedCount: Int {
        return elements.underestimatedCount
    }

    public mutating func set(contents: [Element]) {
        elements = contents
    }

    public mutating func removeAll() {
        elements.removeAll()
        isSelected.removeAll()
    }

    @discardableResult
    public mutating func remove(at i: Int) -> Element {
        let element = elements.remove(at: i)
        isSelected.remove(at: i)
        updateSelections()
        return element        
    }

    @discardableResult
    public mutating func removeFirst() -> Element {
        let element = elements.removeFirst()
        isSelected.removeFirst()
        updateSelections()
        return element
    }

    public mutating func removeFirst(_ k: Int) {
        elements.removeFirst(k)
        isSelected.removeFirst(k)
        updateSelections()
    }

    public mutating func removeSubrange(_ bounds: Range<Int>) {
        elements.removeSubrange(bounds)
        isSelected.removeSubrange(bounds)
        updateSelections()
    }

    public mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
        try elements.removeAll(where: shouldBeRemoved)
        updateSelections()
    }

    public mutating func removeAll(keepingCapacity keepCapacity: Bool) {
        elements.removeAll(keepingCapacity: keepCapacity)
        isSelected.removeAll(keepingCapacity: keepCapacity)
        updateSelections()
    }

    public mutating func removeLast(_ k: Int) {
        elements.removeLast(k)
        isSelected.removeLast(k)
        updateSelections()
    }

    public mutating func removeLast() {
        elements.removeLast()
        isSelected.removeLast()
        updateSelections()
    }

    public mutating func append(_ newElement: Element) {
        elements.append(newElement)
        isSelected.append(false)
        updateSelections()
    }

    public mutating func append<S>(contentsOf newElements: S) where S: Sequence, Element == S.Element {
        let count = elements.count
        elements.append(contentsOf: newElements)
        for _ in 0 ..< (elements.count - count) {
            isSelected.append(false)
        }
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

    public mutating func swapAt(_ i: Int, _ j: Int) {
        elements.swapAt(i, j)
        isSelected.swapAt(i, j)
    }

    public mutating func reserveCapacity(_ n: Int) {
        elements.reserveCapacity(n)
    }

    public mutating func insert(_ newElement: Element, at i: Int) {
        elements.insert(newElement, at: i)
    }

    public mutating func insert<S>(contentsOf newElements: S, at i: Int) where S: Collection, Element == S.Element {
        elements.insert(contentsOf: newElements, at: i)
    }

    public init<S>(_ elements: S) where S: Sequence, Element == S.Element {
        self.elements = .init(elements)
    }

    public init(repeating repeatedValue: Element, count: Int) {
        elements = .init(repeating: repeatedValue, count: count)
    }

    public func formIndex(after i: inout Int) {
        elements.formIndex(after: &i)
    }

    public func formIndex(before i: inout Int) {
        elements.formIndex(before: &i)
    }

    public mutating func partition(by belongsInSecondPartition: (Element) throws -> Bool) rethrows -> Int {
        try elements.partition(by: belongsInSecondPartition)
    }

    public func withContiguousStorageIfAvailable<R>(_ body: (UnsafeBufferPointer<Element>) throws -> R) rethrows -> R? {
        try elements.withContiguousStorageIfAvailable(body)
    }

    public mutating func withContiguousMutableStorageIfAvailable<R>(_ body: (inout UnsafeMutableBufferPointer<Element>) throws -> R) rethrows -> R? {
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

    public subscript(index: Int) -> Element {
        get {  return elements[index] }
        set {  elements[index] = newValue }
    }
    
    public subscript(range: ClosedRange<Int>) -> ArraySlice<Element> {
        get { return elements[range] }
        set { elements[range] = newValue }
    }
    
    public subscript(range: Range<Int>) -> ArraySlice<Element> {
        get { return elements[range] }
        set { elements[range] = newValue }
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

    public mutating func replaceSubrange<C, R>(_ subrange: R, with newElements: C)
        where C: Collection, R: RangeExpression, Element == C.Element, Int == R.Bound
    {
        elements.replaceSubrange(subrange, with: newElements)
    }
    
    public var allowsSelection: Bool = true {
        didSet {
            updateSelections()
        }
    }

    public var allowsMultipleSelection: Bool = false {
        didSet {
            updateSelections()
        }
    }

    public var allowsEmptySelection: Bool = true {
        didSet {
            updateSelections()
        }
    }

    private var isSelected: [Bool] = []

    public var selectedElements: [Element] {
        var selectedElements: [Element] = []
        for (index, i) in isSelected.enumerated() {
            if i == true {
                selectedElements.append(elements[index])
            }
        }
        return selectedElements
    }

    public var selectedIndexes: [Int] {
        var selectedIndexes: [Int] = []
        for (index, i) in isSelected.enumerated() {
            if i == true {
                selectedIndexes.append(index)
            }
        }
        return selectedIndexes
    }

    public mutating func select(at index: Int) {
        select(at: index, exclusivly: false)
    }

    public mutating func select(_ option: AdvanceOption, exclusivly: Bool) {
        switch option {
        case .next:
            if let first = selectedIndexes.first, first + 1 < elements.count {
                select(at: first + 1, exclusivly: exclusivly)
            }
        case .previous:
            if let first = selectedIndexes.first, first - 1 >= 0 {
                select(at: first - 1, exclusivly: exclusivly)
            }
        case .nextLooping:
            if let first = selectedIndexes.first {
                select(at: (first + 1 < elements.count) ? first + 1 : 0, exclusivly: exclusivly)
            }
        case .previousLooping:
            if let first = selectedIndexes.first {
                select(at: (first - 1 >= 0) ? first - 1 : elements.count, exclusivly: exclusivly)
            }
        case .first:
            if elements.isEmpty == false {
                select(at: 0, exclusivly: exclusivly)
            }
        case .last:
            if elements.isEmpty == false {
                select(at: elements.count - 1, exclusivly: exclusivly)
            }
        case .random:
            if elements.isEmpty == false {
                select(at: Int.random(in: 0 ..< elements.count), exclusivly: exclusivly)
            }
        }
    }

    public mutating func select(at index: Int, exclusivly: Bool) {
        guard allowsSelection, index < elements.count else { return }
        if !allowsMultipleSelection || exclusivly == true {
            for i in 0 ..< isSelected.count {
                isSelected[i] = false
            }
        }
        isSelected[index] = true
    }

    public mutating func select(at indexes: [Int]) {
        guard allowsSelection else { return }
        if allowsMultipleSelection {
            indexes.forEach { self.select(at: $0) }
        } else if let firstIndex = indexes.first {
            select(at: firstIndex)
        }
    }

    public mutating func deselect(at index: Int) {
        guard elements.isEmpty == false, index < elements.count else { return }
        isSelected[index] = false
        updateSelections()
    }

    public mutating func deselect(at indexes: [Int]) {
        indexes.forEach { self.deselect(at: $0) }
    }
    
    private mutating func updateSelections() {
        if allowsSelection {
            if allowsMultipleSelection == false, let firstIndex = selectedIndexes.first {
                select(at: firstIndex, exclusivly: true)
            }
            if allowsEmptySelection == false && selectedIndexes.count == 0 {
                select(at: 0)
            }
        } else {
            deselect(at: selectedIndexes)
        }
    }

    public mutating func deselectFirst() {
        guard elements.isEmpty == false else { return }
        deselect(at: 0)
    }

    public mutating func deselectFirst(_ k: Int) {
        let count = elements.count - k
        guard elements.count >= count else { return }
        var deselectIndexes: [Int] = []
        for i in 0 ..< k {
            deselectIndexes.append(i)
        }
        deselect(at: deselectIndexes)
    }

    public mutating func selectFirst() {
        guard elements.isEmpty == false else { return }
        select(at: 0)
    }

    public mutating func selectFirst(_ k: Int) {
        let count = elements.count - k
        guard elements.count >= count else { return }
        var selectIndexes: [Int] = []
        for i in 0 ..< k {
            selectIndexes.append(i)
        }
        select(at: selectIndexes)
    }

    public mutating func deselectLast() {
        guard elements.isEmpty == false else { return }
        deselect(at: elements.count - 1)
    }

    public mutating func deselectLast(_ k: Int) {
        let count = elements.count - k
        guard elements.count >= count else { return }
        var deselectIndexes: [Int] = []
        for i in 0 ..< k {
            deselectIndexes.append(elements.count - 1 + i)
        }
        deselect(at: deselectIndexes)
    }

    public mutating func selectLast() {
        guard elements.isEmpty == false else { return }
        select(at: elements.count - 1)
    }

    public mutating func selectLast(_ k: Int) {
        let count = elements.count - k
        guard elements.count >= count else { return }
        var selectIndexes: [Int] = []
        for i in 0 ..< k {
            selectIndexes.append(elements.count - 1 + i)
        }
        select(at: selectIndexes)
    }
}

extension SelectableArray: Sendable where Element: Sendable { }

extension SelectableArray: Encodable where Element: Encodable {}

extension SelectableArray: Decodable where Element: Decodable {}

extension SelectableArray: CVarArg {
    public var _cVarArgEncoding: [Int] {
        return elements._cVarArgEncoding
    }
}

extension SelectableArray: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
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

extension SelectableArray: Hashable where Element: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(elements)
    }
}

extension SelectableArray: ContiguousBytes {
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        try elements.withUnsafeBytes(body)
    }
}

extension SelectableArray: Equatable where Element: Equatable {
    public static func == (lhs: SelectableArray<Element>, rhs: SelectableArray<Element>) -> Bool {
        return lhs.elements == rhs.elements
    }
}

extension SelectableArray: ExpressibleByArrayLiteral {}
