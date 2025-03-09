//
//  SelectableArray.swift
//
//
//  Created by Florian Zand on 15.10.21.
//

import Foundation

/// An array with selectable elements.
public struct SelectableArray<Element>: MutableCollection, RangeReplaceableCollection, RandomAccessCollection, BidirectionalCollection {
    var elements: [SelectedElement] = [] {
        didSet { updateSelections() }
    }
    
    struct SelectedElement {
        var element: Element
        var isSelected: Bool
        init(_ element: Element, isSelected: Bool = false) {
            self.element = element
            self.isSelected = isSelected
        }
    }

    public init() {}

    public init(arrayLiteral elements: Element...) {
        self.elements = elements.compactMap({SelectedElement($0)})
    }

    public init<S>(_ elements: S) where S: Sequence, Element == S.Element {
        self.elements = Array(elements).compactMap({SelectedElement($0)})
    }

    public init(repeating repeatedValue: Element, count: Int) {
        elements = Array(repeating: repeatedValue, count: count).compactMap({SelectedElement($0)})
    }

    public var count: Int {
        elements.count
    }

    public var isEmpty: Bool {
        elements.isEmpty
    }

    public var startIndex: Int {
        elements.startIndex
    }

    public var endIndex: Int {
        elements.endIndex
    }

    public subscript(index: Int) -> Element {
        get { elements[index].element }
        set { elements[index].element = newValue }
    }

    public mutating func replaceSubrange<C, R>(_ subrange: R, with newElements: C)
        where C: Collection, R: RangeExpression, Element == C.Element, Int == R.Bound
    {
        let range = subrange.relative(to: elements.indices)
        var newSelectedElements: [SelectedElement] = []
        for (offset, newElement) in newElements.enumerated() {
            let index = range.lowerBound + offset
            newSelectedElements.append(SelectedElement(newElement, isSelected: elements[safe: index]?.isSelected ?? false))
        }
        elements.replaceSubrange(subrange, with: newSelectedElements)
    }
    
    // MARK: - Selection

    public var allowsSelection: Bool = true {
        didSet { updateSelections() }
    }

    public var allowsMultipleSelection: Bool = false {
        didSet { updateSelections() }
    }

    public var allowsEmptySelection: Bool = true {
        didSet { updateSelections() }
    }

    public var selectedElements: [Element] {
        elements.filter({$0.isSelected}).compactMap({$0.element})
    }
    
    public var selectedIndexes: [Int] {
        elements.indexes(where: {$0.isSelected})
    }
    
    public var nonSelectedElements: [Element] {
        elements.filter({!$0.isSelected}).compactMap({$0.element})
    }
    
    public var nonSelectedIndexes: [Int] {
        elements.indexes(where: {!$0.isSelected})
    }
    
    public func isSelected(at index: Index) -> Bool {
        elements[safe: index]?.isSelected ?? false
    }
    
    public func isSelected(for element: Element) -> Bool where Element: Equatable {
        elements.first(where: {$0.element == element })?.isSelected ?? false
    }
    
    public func isSelected(for element: Element) -> Bool where Element: AnyObject {
        elements.first(where: {$0.element === element })?.isSelected ?? false
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
            if !elements.isEmpty {
                select(at: 0, exclusivly: exclusivly)
            }
        case .last:
            if !elements.isEmpty {
                select(at: elements.count - 1, exclusivly: exclusivly)
            }
        case .random:
            if !elements.isEmpty {
                select(at: Int.random(in: 0 ..< elements.count), exclusivly: exclusivly)
            }
        }
    }

    public mutating func select(at index: Int, exclusivly: Bool) {
        guard allowsSelection, index < elements.count else { return }
        if !allowsMultipleSelection || exclusivly == true {
            for i in 0 ..< elements.count {
                elements[i].isSelected = false
            }
        }
        elements[index].isSelected = true
    }

    public mutating func select(at indexes: [Int]) {
        guard allowsSelection else { return }
        if allowsMultipleSelection {
            indexes.forEach { select(at: $0) }
        } else if let firstIndex = indexes.first {
            select(at: firstIndex)
        }
    }

    public mutating func deselect(at index: Int) {
        guard !elements.isEmpty, index < elements.count else { return }
        elements[index].isSelected = false
        updateSelections()
    }

    public mutating func deselect(at indexes: [Int]) {
        indexes.forEach { deselect(at: $0) }
    }

    private mutating func updateSelections() {
        if allowsSelection {
            if !allowsMultipleSelection, let firstIndex = selectedIndexes.first {
                select(at: firstIndex, exclusivly: true)
            }
            if !allowsEmptySelection, selectedIndexes.count == 0 {
                select(at: 0)
            }
        } else {
            deselect(at: selectedIndexes)
        }
    }

    public mutating func deselectFirst() {
        guard !elements.isEmpty else { return }
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
        guard !elements.isEmpty else { return }
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
        guard !elements.isEmpty else { return }
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
        guard !elements.isEmpty else { return }
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
    
    public mutating func append(_ newElement: Element, isSelected: Bool) {
        elements.append(.init(newElement, isSelected: isSelected))
        updateSelections()
    }
    
    public mutating func append<S>(contentsOf newElements: S, isSelected: Bool) where S: Sequence, Element == S.Element {
        elements.append(contentsOf: newElements.compactMap({SelectedElement($0, isSelected: isSelected)}))
        updateSelections()
    }
    
    public mutating func replaceSubrange<C, R>(_ subrange: R, with newElements: C, isSelected: Bool) where C: Collection, R: RangeExpression, Element == C.Element, Int == R.Bound {
        elements.replaceSubrange(subrange, with: newElements.compactMap({ SelectedElement($0, isSelected: isSelected) }))
        updateSelections()
    }
    
    public mutating func insert<S>(contentsOf newElements: S, at i: Int, isSelected: Bool) where S: Collection, Element == S.Element {
        elements.insert(contentsOf: newElements.compactMap({SelectedElement($0, isSelected: isSelected)}), at: i)
        updateSelections()
    }
}

extension SelectableArray: ExpressibleByArrayLiteral {}
extension SelectableArray: Sendable where Element: Sendable {}
extension SelectableArray: Encodable where Element: Encodable {}
extension SelectableArray: Decodable where Element: Decodable {}

extension SelectableArray: CVarArg {
    public var _cVarArgEncoding: [Int] {
        elements._cVarArgEncoding
    }
}

extension SelectableArray: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    public var customMirror: Mirror {
        elements.customMirror
    }

    public var debugDescription: String {
        elements.debugDescription
    }

    public var description: String {
        elements.description
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
        lhs.elements == rhs.elements
    }
}

extension SelectableArray.SelectedElement: Equatable where Element: Equatable { }
extension SelectableArray.SelectedElement: Hashable where Element: Hashable { }
extension SelectableArray.SelectedElement: Encodable where Element: Encodable { }
extension SelectableArray.SelectedElement: Decodable where Element: Decodable { }
