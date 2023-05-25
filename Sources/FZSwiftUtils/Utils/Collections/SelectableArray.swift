//
//  ArrayBase.swift
//  Selectable
//
//  Created by Florian Zand on 15.10.21.
//


import Foundation

open class SelectableArray<ElementType>: BaseArray<ElementType> {
    public var allowsSelection: Bool = true  {
        didSet {
            self.updateSelections()
        }
    }
    
    public var allowsMultipleSelection: Bool = false  {
         didSet {
             self.updateSelections()
         }
     }
     
     public var allowsEmptySelection: Bool = true  {
         didSet {
             self.updateSelections()
         }
     }
    
    private var isSelected: [Bool] = []

    public var selectedElements: [ElementType] {
        var selectedElements: [ElementType] = []
        for (index, i) in isSelected.enumerated() {
            if (i == true) {
                selectedElements.append(self.elements[index])
            }
        }
        return selectedElements
    }
        
    public var selectedIndexes: [Int] {
        var selectedIndexes: [Int] = []
        for (index, i) in isSelected.enumerated() {
            if (i == true) {
                selectedIndexes.append(index)
            }
        }
        return selectedIndexes
    }
    
   public func select(at index: Int) {
        self.select(at: index, exclusivly: false)
    }
    
    public func select(_ option: AdvanceOption, exclusivly: Bool) {
        switch option {
        case .next:
            if let first = self.selectedIndexes.first, first + 1 < self.elements.count {
                self.select(at: first + 1, exclusivly: exclusivly)
            }
        case .previous:
            if let first = self.selectedIndexes.first, first - 1 >= 0 {
                self.select(at: first - 1, exclusivly: exclusivly)
            }
        case .nextLooping:
            if let first = self.selectedIndexes.first {
                self.select(at: (first + 1 < self.elements.count) ? first + 1 : 0, exclusivly: exclusivly)
            }
        case .previousLooping:
            if let first = self.selectedIndexes.first {
                self.select(at: (first - 1 >= 0) ? first - 1 : self.elements.count, exclusivly: exclusivly)
            }
        case .first:
            if (self.elements.isEmpty == false) {
                self.select(at: 0, exclusivly: exclusivly)
            }
        case .last:
            if (self.elements.isEmpty == false) {
                self.select(at: self.elements.count - 1, exclusivly: exclusivly)
            }
        case .random:
            if (self.elements.isEmpty == false) {
                self.select(at: Int.random(in: 0..<self.elements.count), exclusivly: exclusivly)
            }
        }
    }
    
   public func select(at index: Int, exclusivly: Bool) {
       guard allowsSelection, index < elements.count else { return }
            if (!allowsMultipleSelection || exclusivly == true) {
                for i in 0..<self.isSelected.count {
                    isSelected[i] = false
                }
            }
       isSelected[index] = true
    }
    
    public func select(at indexes: [Int]) {
        guard allowsSelection else { return }
        if (self.allowsMultipleSelection) {
            indexes.forEach({self.select(at: $0)})
        } else if let firstIndex = indexes.first {
            self.select(at: firstIndex)
        }
    }
    
    public func deselect(at index: Int) {
        guard self.elements.isEmpty == false, index < elements.count else { return }
        self.isSelected[index] = false
        self.updateSelections()
    }
    
    public func deselect(at indexes: [Int]) {
        indexes.forEach({self.deselect(at: $0)})
    }
    
    public override func swapAt(_ i: Int, _ j: Int) {
        super.swapAt(i, j)
        self.isSelected.swapAt(i, j)
    }
    
    public override func append(_ newElement: ElementType) {
        super.append(newElement)
        isSelected.append(false)
        self.updateSelections()
    }
    
    
    public override func append<S>(contentsOf newElements: S) where ElementType == S.Element, S : Sequence {
        let count = self.elements.count
        super.append(contentsOf: newElements)
        for _ in 0..<(self.elements.count - count) {
            self.isSelected.append(false)
        }
    }
    
    @discardableResult
    public override func removeFirst() -> ElementType {
       let element = super.removeFirst()
        self.isSelected.removeFirst()
        self.updateSelections()
        return element
    }
    
    @discardableResult
    public override func remove(at i: Int) -> ElementType {
        let element = super.remove(at: i)
        self.isSelected.remove(at: i)
        self.updateSelections()
        return element
    }
    
    public override func removeFirst(_ k: Int) {
        super.removeFirst(k)
        self.isSelected.removeFirst(k)
        self.updateSelections()
    }
    
    public override func removeAll() {
        super.removeAll()
        self.isSelected.removeAll()
    }
    
    public func removeSelected() {
        self.selectedIndexes.enumerated().forEach({ self.remove(at: $0.0 - $0.1)  })
    }
        
    public override func removeSubrange(_ bounds: Range<Int>) {
        super.removeSubrange(bounds)
        self.isSelected.removeSubrange(bounds)
        self.updateSelections()
    }
    
    public override func removeAll(where shouldBeRemoved: (ElementType) throws -> Bool) rethrows {
        try super.removeAll(where: shouldBeRemoved)
        self.updateSelections()
    }
    
    public override func removeLast(_ k: Int) {
        super.removeLast(k)
        self.isSelected.removeLast(k)
        self.updateSelections()
    }
    
    public override func removeLast() {
        super.removeLast()
        self.isSelected.removeLast()
        self.updateSelections()

    }
    
    public override func removeAll(keepingCapacity keepCapacity: Bool) {
        super.removeAll(keepingCapacity: keepCapacity)
        self.isSelected.removeAll(keepingCapacity: keepCapacity)
        self.updateSelections()
    }
    
    private func updateSelections() {
        if (allowsSelection) {
            if allowsMultipleSelection == false, let firstIndex = self.selectedIndexes.first {
                self.select(at: firstIndex, exclusivly: true)
            }
            if (allowsEmptySelection == false && self.selectedIndexes.count == 0) {
                self.select(at: 0)
            }
        } else {
            self.deselect(at: selectedIndexes)
        }
    }
    
    public func deselectFirst() {
        guard self.elements.isEmpty == false else { return }
        self.deselect(at: 0)
    }
    
    public func deselectFirst(_ k: Int) {
        let count = self.elements.count - k
        guard self.elements.count >= count else { return }
        var deselectIndexes: [Int] = []
        for i in 0..<k {
            deselectIndexes.append(i)
        }
        self.deselect(at: deselectIndexes)
    }
    
    public func selectFirst() {
        guard self.elements.isEmpty == false else { return }
        self.select(at: 0)
    }
    
    public func selectFirst(_ k: Int) {
        let count = self.elements.count - k
        guard self.elements.count >= count else { return }
        var selectIndexes: [Int] = []
        for i in 0..<k {
            selectIndexes.append(i)
        }
        self.select(at: selectIndexes)
    }
    
    public func deselectLast() {
        guard self.elements.isEmpty == false else { return }
        self.deselect(at: self.elements.count - 1)
    }
    
    public func deselectLast(_ k: Int) {
        let count = self.elements.count - k
        guard self.elements.count >= count else { return }
        var deselectIndexes: [Int] = []
        for i in 0..<k {
            deselectIndexes.append(self.elements.count-1+i)
        }
        self.deselect(at: deselectIndexes)
    }
    
    public func selectLast() {
        guard self.elements.isEmpty == false else { return }
        self.select(at: self.elements.count - 1)
    }
    
    public func selectLast(_ k: Int) {
        let count = self.elements.count - k
        guard self.elements.count >= count else { return }
        var selectIndexes: [Int] = []
        for i in 0..<k {
            selectIndexes.append(self.elements.count-1+i)
        }
        self.select(at: selectIndexes)
    }
}
