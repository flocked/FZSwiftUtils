//
//  OrderedSet.swift
//
//
//  Created by 1024jp on 2016-03-21.
//  © 2017-2022 1024jp

struct OrderedSet<Element: Hashable>: RandomAccessCollection {
    typealias Index = Array<Element>.Index

    private var elements: [Element] = []

    // MARK: -

    // MARK: Lifecycle

    init() {}

    init(_ elements: some Sequence<Element>) {
        append(contentsOf: elements)
    }

    // MARK: Collection Methods

    /// return the element at the specified position.
    subscript(_ index: Index) -> Element {
        elements[index]
    }

    var startIndex: Index {
        elements.startIndex
    }

    var endIndex: Index {
        elements.endIndex
    }

    func index(after index: Index) -> Index {
        elements.index(after: index)
    }

    // MARK: Methods

    var array: [Element] {
        elements
    }

    var set: Set<Element> {
        Set(elements)
    }

    /// return a new set with the elements that are common to both this set and the given sequence.
    func intersection(_ other: some Sequence<Element>) -> Self {
        var set = OrderedSet()
        set.elements = elements.filter { other.contains($0) }

        return set
    }

    // MARK: Mutating Methods

    /// insert the given element in the set if it is not already present.
    mutating func append(_ element: Element) {
        guard !elements.contains(element) else { return }

        elements.append(element)
    }

    /// insert the given elements in the set only which it is not already present.
    mutating func append(contentsOf elements: some Sequence<Element>) {
        for element in elements {
            append(element)
        }
    }

    /// insert the given element at the desired position.
    mutating func insert(_ element: Element, at index: Index) {
        guard !elements.contains(element) else { return }

        elements.insert(element, at: index)
    }

    /// remove the elements of the set that aren’t also in the given sequence.
    mutating func formIntersection(_ other: some Sequence<Element>) {
        elements.removeAll { !other.contains($0) }
    }

    /// remove the the element at the position from the set.
    @discardableResult
    mutating func remove(at index: Index) -> Element {
        elements.remove(at: index)
    }

    /// remove the specified element from the set.
    @discardableResult
    mutating func remove(_ element: Element) -> Element? {
        guard let index = firstIndex(of: element) else { return nil }

        return remove(at: index)
    }
}
