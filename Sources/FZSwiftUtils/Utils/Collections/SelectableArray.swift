//
//  ArrayBase.swift
//  Selectable
//
//  Created by Florian Zand on 15.10.21.
//

import Foundation

open class SelectableArray<ElementType>: BaseArray<ElementType> {
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

    public var selectedElements: [ElementType] {
        var selectedElements: [ElementType] = []
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

    public func select(at index: Int) {
        select(at: index, exclusivly: false)
    }

    public func select(_ option: AdvanceOption, exclusivly: Bool) {
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

    public func select(at index: Int, exclusivly: Bool) {
        guard allowsSelection, index < elements.count else { return }
        if !allowsMultipleSelection || exclusivly == true {
            for i in 0 ..< isSelected.count {
                isSelected[i] = false
            }
        }
        isSelected[index] = true
    }

    public func select(at indexes: [Int]) {
        guard allowsSelection else { return }
        if allowsMultipleSelection {
            indexes.forEach { self.select(at: $0) }
        } else if let firstIndex = indexes.first {
            select(at: firstIndex)
        }
    }

    public func deselect(at index: Int) {
        guard elements.isEmpty == false, index < elements.count else { return }
        isSelected[index] = false
        updateSelections()
    }

    public func deselect(at indexes: [Int]) {
        indexes.forEach { self.deselect(at: $0) }
    }

    override public func swapAt(_ i: Int, _ j: Int) {
        super.swapAt(i, j)
        isSelected.swapAt(i, j)
    }

    override public func append(_ newElement: ElementType) {
        super.append(newElement)
        isSelected.append(false)
        updateSelections()
    }

    override public func append<S>(contentsOf newElements: S) where ElementType == S.Element, S: Sequence {
        let count = elements.count
        super.append(contentsOf: newElements)
        for _ in 0 ..< (elements.count - count) {
            isSelected.append(false)
        }
    }

    @discardableResult
    override public func removeFirst() -> ElementType {
        let element = super.removeFirst()
        isSelected.removeFirst()
        updateSelections()
        return element
    }

    @discardableResult
    override public func remove(at i: Int) -> ElementType {
        let element = super.remove(at: i)
        isSelected.remove(at: i)
        updateSelections()
        return element
    }

    override public func removeFirst(_ k: Int) {
        super.removeFirst(k)
        isSelected.removeFirst(k)
        updateSelections()
    }

    override public func removeAll() {
        super.removeAll()
        isSelected.removeAll()
    }

    public func removeSelected() {
        selectedIndexes.enumerated().forEach { self.remove(at: $0.0 - $0.1) }
    }

    override public func removeSubrange(_ bounds: Range<Int>) {
        super.removeSubrange(bounds)
        isSelected.removeSubrange(bounds)
        updateSelections()
    }

    override public func removeAll(where shouldBeRemoved: (ElementType) throws -> Bool) rethrows {
        try super.removeAll(where: shouldBeRemoved)
        updateSelections()
    }

    override public func removeLast(_ k: Int) {
        super.removeLast(k)
        isSelected.removeLast(k)
        updateSelections()
    }

    override public func removeLast() {
        super.removeLast()
        isSelected.removeLast()
        updateSelections()
    }

    override public func removeAll(keepingCapacity keepCapacity: Bool) {
        super.removeAll(keepingCapacity: keepCapacity)
        isSelected.removeAll(keepingCapacity: keepCapacity)
        updateSelections()
    }

    private func updateSelections() {
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

    public func deselectFirst() {
        guard elements.isEmpty == false else { return }
        deselect(at: 0)
    }

    public func deselectFirst(_ k: Int) {
        let count = elements.count - k
        guard elements.count >= count else { return }
        var deselectIndexes: [Int] = []
        for i in 0 ..< k {
            deselectIndexes.append(i)
        }
        deselect(at: deselectIndexes)
    }

    public func selectFirst() {
        guard elements.isEmpty == false else { return }
        select(at: 0)
    }

    public func selectFirst(_ k: Int) {
        let count = elements.count - k
        guard elements.count >= count else { return }
        var selectIndexes: [Int] = []
        for i in 0 ..< k {
            selectIndexes.append(i)
        }
        select(at: selectIndexes)
    }

    public func deselectLast() {
        guard elements.isEmpty == false else { return }
        deselect(at: elements.count - 1)
    }

    public func deselectLast(_ k: Int) {
        let count = elements.count - k
        guard elements.count >= count else { return }
        var deselectIndexes: [Int] = []
        for i in 0 ..< k {
            deselectIndexes.append(elements.count - 1 + i)
        }
        deselect(at: deselectIndexes)
    }

    public func selectLast() {
        guard elements.isEmpty == false else { return }
        select(at: elements.count - 1)
    }

    public func selectLast(_ k: Int) {
        let count = elements.count - k
        guard elements.count >= count else { return }
        var selectIndexes: [Int] = []
        for i in 0 ..< k {
            selectIndexes.append(elements.count - 1 + i)
        }
        select(at: selectIndexes)
    }
}
