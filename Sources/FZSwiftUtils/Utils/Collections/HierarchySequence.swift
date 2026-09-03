//
//  HierarchySequence.swift
//  FZSwiftUtils
//
//  Created by Florian Zand on 28.08.26.
//

import Foundation

/**
 A sequence that traverses Elements in a hierarchical structure.

 ``HierarchySequence`` traverses Elements whose children are provided by a key path
 or closure. By default, Elements are traversed in depth-first preorder and the root Element itself
 isn't included in the sequence.

 Use ``HierarchySequence/includeRoot()`` to include the root Element, ``HierarchySequence/minDepth(_:)`` and
 ``HierarchySequence/maxDepth(_:)`` to limit the traversal depth, and
 ``HierarchySequence/maxChildrenPerElement(_:)`` to limit the number of children traversed for each Element.
 Use ``HierarchySequence/breadthFirst()`` or ``HierarchySequence/depthFirstPostorder()`` to change the traversal order.

 The sequence's iterator exposes the index and depth of the Element most recently
 returned by ``HierarchySequence/Iterator/next()``. When iterating manually, you can also use
 ``HierarchySequence/Iterator/skipDescendants()`` and ``HierarchySequence/Iterator/skipRemainingSiblings()`` to control
 traversal.

 ```swift
 let sequence = HierarchySequence(root: root, children: \.children)
     .includeRoot()
     .maxDepth(3)

 var iterator = sequence.makeIterator()

 while let Element = iterator.next() {
     print(iterator.depth, iterator.index, Element)

     if shouldSkipChildren(of: Element) {
         iterator.skipDescendants()
     }
 }
 */
public struct HierarchySequence<Element, Children: Collection>: Sequence where Children.Element == Element {
    public typealias Element = Element

    private enum TraversalOrder {
        case depthFirst
        case depthFirstPostorder
        case breadthFirst
    }

    private var minDepth: Int = 0
    private var maxDepth: Int = .max
    private var maxChildrenPerElement: Int = .max
    private var includingRoot = false
    private var traversalOrder: TraversalOrder = .depthFirst
    private var childComparator: ((Element, Element) -> Bool)?
    private var matchPredicate: ((Element) -> Bool)?

    private let root: Element
    private let children: (Element) -> Children?

    /**
     Creates a hierarchy sequence for the children at the specified key path of the given root Element.

     - Parameters:
       - root: The root Element of the hierarchy.
       - keyPath: A key path to the collection containing each Element's children.
     */
    public init(root: Element, children keyPath: KeyPath<Element, Children>) {
        self.init(root: root, children: { $0[keyPath: keyPath] })
    }

    /**
     Creates a hierarchy sequence for the children at the specified key path of the given root Element.

     - Parameters:
       - root: The root Element of the hierarchy.
       - keyPath: A key path to the collection containing each Element's children.
     */
    public init(root: Element, children keyPath: KeyPath<Element, Children?>) {
        self.init(root: root, children: { $0[keyPath: keyPath] })
    }

    /**
     Creates a hierarchy sequence whose children are provided by the specified closure.

     - Parameters:
       - root: The root Element of the hierarchy.
       - children: A closure that returns the children of a Element.
     */
    public init(root: Element, children: @escaping (Element) -> Children?) {
        self.root = root
        self.children = children
    }

    /// Returns a sequence that includes the root Element.
    public func includeRoot() -> Self {
        var sequence = self
        sequence.includingRoot = true
        return sequence
    }

    /// Returns a sequence that only enumerates Elements at or below the specified minimum depth.
    public func minDepth(_ minDepth: Int) -> Self {
        var sequence = self
        sequence.minDepth = minDepth.clamped(min: 0)
        return sequence
    }

    /// Returns a sequence that limits enumeration to the specified maximum depth.
    public func maxDepth(_ maxDepth: Int) -> Self {
        var sequence = self
        sequence.maxDepth = maxDepth.clamped(min: 0)
        return sequence
    }

    /// Returns a sequence that limits the number of children enumerated for each Element.
    public func maxChildrenPerElement(_ maxChildren: Int) -> Self {
        var sequence = self
        sequence.maxChildrenPerElement = maxChildren.clamped(min: 0)
        return sequence
    }

    /// Returns a sequence that traverses Elements in breadth-first order.
    public func breadthFirst() -> Self {
        var sequence = self
        sequence.traversalOrder = .breadthFirst
        return sequence
    }

    /// Returns a sequence that traverses Elements in depth-first postorder.
    public func depthFirstPostorder() -> Self {
        var sequence = self
        sequence.traversalOrder = .depthFirstPostorder
        return sequence
    }

    /// Returns a sequence that sorts the children of each Element using the specified comparator.
    public func sortingChildren(using comparator: some SortComparator<Element>) -> Self {
        var sequence = self
        sequence.childComparator = {
            comparator.compare($0, $1) == .orderedAscending
        }
        return sequence
    }

    /// Returns a sequence that sorts the children of each Element using the specified comparator.
    public func sortingChildren(by areInIncreasingOrder: @escaping (Element, Element) -> Bool) -> Self {
        var sequence = self
        sequence.childComparator = areInIncreasingOrder
        return sequence
    }

    /// Returns a sequence that includes Elements matching the predicate or containing a matching descendant.
    public func includingBranches(
        matching predicate: @escaping (Element) -> Bool
    ) -> Self {
        var sequence = self
        sequence.matchPredicate = predicate
        return sequence
    }

    /// Returns an iterator over the Elements in the hierarchy.
    public func makeIterator() -> Iterator {
        Iterator(sequence: self)
    }

    public struct Iterator: IteratorProtocol {

        /// The depth of the Element most recently returned by `next()`, where the root has a depth of `0`.
        public var depth: Int {
            indexPath.count
        }

        /// The index of the Element most recently returned by `next()` within its parent's children.
        public var index: Int {
            indexPath.last ?? 0
        }

        /// The index path of the Element most recently returned by `next()` within the hierarchy.
        public private(set) var indexPath = IndexPath()

        /// The ancestors of the Element most recently returned by `next()`, ordered from the root to the immediate parent.
        public private(set) var ancestors: [Element] = []

        /// The parent of the Element most recently returned by `next()`, or `nil` if the Element is the root.
        public var parent: Element? {
            ancestors.last
        }

        private enum ChildIterator {
            case collection(Children.Iterator)
            case array(Array<Element>.Iterator)

            mutating func next() -> Element? {
                switch self {
                case .collection(var iterator):
                    let Element = iterator.next()
                    self = .collection(iterator)
                    return Element

                case .array(var iterator):
                    let Element = iterator.next()
                    self = .array(iterator)
                    return Element
                }
            }
        }

        private struct Frame {
            let Element: Element
            let indexPath: IndexPath
            var iterator: ChildIterator
            var index = 0
            var skipsRemainingSiblings = false
        }

        private struct PostorderFrame {
            let Element: Element
            let indexPath: IndexPath
            let isIncluded: Bool
            var iterator: ChildIterator?
            var index = 0
            var skipsRemainingSiblings = false
        }

        private struct QueuedElement {
            let Element: Element
            let indexPath: IndexPath
            let depth: Int
            let ancestors: [Element]
            let siblingGroup: Int?
        }

        private let children: (Element) -> Children?
        private let childComparator: ((Element, Element) -> Bool)?
        private let matchPredicate: ((Element) -> Bool)?
        private let minDepth: Int
        private let maxDepth: Int
        private let maxChildrenPerElement: Int
        private let traversalOrder: TraversalOrder

        private var root: Element?
        private var currentElement: Element?
        private var currentIndexPath = IndexPath()

        // Depth-first state.
        private var frames: [Frame] = []

        // Depth-first postorder state.
        private var postorderFrames: [PostorderFrame] = []

        // Breadth-first state.
        private var queue: [QueuedElement] = []
        private var queueIndex = 0
        private var nextSiblingGroup = 0
        private var currentSiblingGroup: Int?
        private var skippedSiblingGroups: Set<Int> = []

        // Filtering state.
        private var matchCache: [IndexPath: Bool] = [:]

        // State applying to the Element most recently returned by next().
        private var skipsDescendants = false
        private var skipsRemainingSiblings = false

        fileprivate init(sequence: HierarchySequence) {
            self.minDepth = sequence.minDepth
            self.maxDepth = sequence.maxDepth
            self.maxChildrenPerElement = sequence.maxChildrenPerElement
            self.children = sequence.children
            self.childComparator = sequence.childComparator
            self.matchPredicate = sequence.matchPredicate
            self.traversalOrder = sequence.traversalOrder

            switch traversalOrder {
            case .depthFirst:
                if sequence.includingRoot {
                    root = sequence.root
                } else {
                    root = nil

                    if maxDepth > 0,
                       maxChildrenPerElement > 0,
                       let children = children(sequence.root),
                       !children.isEmpty
                    {
                        frames.append(
                            Frame(
                                Element: sequence.root,
                                indexPath: IndexPath(),
                                iterator: makeChildIterator(children)
                            )
                        )
                    }
                }

            case .depthFirstPostorder:
                root = nil

                postorderFrames.append(
                    makePostorderFrame(
                        Element: sequence.root,
                        indexPath: IndexPath(),
                        isIncluded: sequence.includingRoot
                    )
                )

            case .breadthFirst:
                root = nil

                if sequence.includingRoot {
                    queue.append(
                        QueuedElement(
                            Element: sequence.root,
                            indexPath: IndexPath(),
                            depth: 0,
                            ancestors: [],
                            siblingGroup: nil
                        )
                    )
                } else if maxDepth > 0,
                          maxChildrenPerElement > 0,
                          let children = children(sequence.root),
                          !children.isEmpty
                {
                    enqueue(
                        children,
                        parentIndexPath: IndexPath(),
                        depth: 1,
                        ancestors: [sequence.root]
                    )
                }
            }
        }

        /**
         Returns the next Element in the hierarchy.

         Elements are returned using the sequence's traversal order. After a Element is returned,
         ``index``, ``depth``, and ``indexPath`` describe that Element until the next call to `next()`.
         */
        public mutating func next() -> Element? {
            switch traversalOrder {
            case .depthFirst:
                nextDepthFirst()

            case .depthFirstPostorder:
                nextDepthFirstPostorder()

            case .breadthFirst:
                nextBreadthFirst()
            }
        }

        /**
         Skips the descendants of the Element most recently returned by `next()`.

         This method has no effect during depth-first postorder traversal because the Element's
         descendants have already been traversed.
         */
        public mutating func skipDescendants() {
            guard currentElement != nil,
                  traversalOrder != .depthFirstPostorder
            else {
                return
            }

            skipsDescendants = true
        }

        /// Skips the remaining siblings of the Element most recently returned by `next()`.
        public mutating func skipRemainingSiblings() {
            guard currentElement != nil else { return }
            skipsRemainingSiblings = true
        }

        // MARK: - Depth-first

        private mutating func nextDepthFirst() -> Element? {
            if let currentElement {
                if skipsRemainingSiblings, !frames.isEmpty {
                    frames[frames.count - 1].skipsRemainingSiblings = true
                }

                if !skipsDescendants {
                    appendFrameIfNeeded(
                        for: currentElement,
                        at: currentIndexPath
                    )
                }

                resetCurrentElement()
            }

            if let root {
                self.root = nil

                let rootIndexPath = IndexPath()

                guard matches(
                    root,
                    at: rootIndexPath,
                    depth: 0
                ) else {
                    return nextDepthFirst()
                }

                if minDepth == 0 {
                    currentElement = root
                    currentIndexPath = rootIndexPath

                    indexPath = rootIndexPath
                    ancestors = []

                    return root
                }

                appendFrameIfNeeded(
                    for: root,
                    at: rootIndexPath
                )
            }

            while !frames.isEmpty {
                let frameIndex = frames.count - 1

                if frames[frameIndex].skipsRemainingSiblings ||
                   frames[frameIndex].index >= maxChildrenPerElement
                {
                    frames.removeLast()
                    continue
                }

                guard let Element = frames[frameIndex].iterator.next() else {
                    frames.removeLast()
                    continue
                }

                let childIndex = frames[frameIndex].index
                frames[frameIndex].index += 1

                let childDepth = frames.count
                let childIndexPath = frames[frameIndex].indexPath.appending(childIndex)

                guard matches(
                    Element,
                    at: childIndexPath,
                    depth: childDepth
                ) else {
                    continue
                }

                if childDepth < minDepth {
                    appendFrameIfNeeded(
                        for: Element,
                        at: childIndexPath
                    )
                    continue
                }

                indexPath = childIndexPath
                ancestors = frames.map(\.Element)

                currentElement = Element
                currentIndexPath = childIndexPath

                return Element
            }

            return nil
        }

        private mutating func appendFrameIfNeeded(
            for Element: Element,
            at indexPath: IndexPath
        ) {
            guard indexPath.count < maxDepth,
                  maxChildrenPerElement > 0,
                  let children = children(Element),
                  !children.isEmpty
            else {
                return
            }

            frames.append(
                Frame(
                    Element: Element,
                    indexPath: indexPath,
                    iterator: makeChildIterator(children)
                )
            )
        }

        // MARK: - Depth-first postorder

        private mutating func nextDepthFirstPostorder() -> Element? {
            if currentElement != nil {
                if skipsRemainingSiblings,
                   !postorderFrames.isEmpty
                {
                    postorderFrames[
                        postorderFrames.count - 1
                    ].skipsRemainingSiblings = true
                }

                resetCurrentElement()
            }

            while !postorderFrames.isEmpty {
                let frameIndex = postorderFrames.count - 1

                if !postorderFrames[frameIndex].skipsRemainingSiblings,
                   postorderFrames[frameIndex].index < maxChildrenPerElement,
                   var iterator = postorderFrames[frameIndex].iterator
                {
                    if let child = iterator.next() {
                        let childIndex = postorderFrames[frameIndex].index

                        postorderFrames[frameIndex].iterator = iterator
                        postorderFrames[frameIndex].index += 1

                        let childIndexPath =
                            postorderFrames[frameIndex].indexPath.appending(childIndex)

                        guard matches(
                            child,
                            at: childIndexPath,
                            depth: childIndexPath.count
                        ) else {
                            continue
                        }

                        postorderFrames.append(
                            makePostorderFrame(
                                Element: child,
                                indexPath: childIndexPath,
                                isIncluded: true
                            )
                        )

                        continue
                    }

                    postorderFrames[frameIndex].iterator = nil
                }

                let frame = postorderFrames.removeLast()

                guard frame.isIncluded,
                      frame.indexPath.count >= minDepth,
                      matches(
                        frame.Element,
                        at: frame.indexPath,
                        depth: frame.indexPath.count
                      )
                else {
                    continue
                }

                currentElement = frame.Element
                currentIndexPath = frame.indexPath

                indexPath = frame.indexPath
                ancestors = postorderFrames.map(\.Element)

                return frame.Element
            }

            return nil
        }

        private func makePostorderFrame(
            Element: Element,
            indexPath: IndexPath,
            isIncluded: Bool
        ) -> PostorderFrame {
            let iterator: ChildIterator?

            if indexPath.count < maxDepth,
               maxChildrenPerElement > 0,
               let children = children(Element),
               !children.isEmpty
            {
                iterator = makeChildIterator(children)
            } else {
                iterator = nil
            }

            return PostorderFrame(
                Element: Element,
                indexPath: indexPath,
                isIncluded: isIncluded,
                iterator: iterator
            )
        }

        // MARK: - Breadth-first

        private mutating func nextBreadthFirst() -> Element? {
            if let currentElement {
                if skipsRemainingSiblings,
                   let currentSiblingGroup
                {
                    skippedSiblingGroups.insert(currentSiblingGroup)
                }

                if !skipsDescendants {
                    enqueueChildrenIfNeeded(
                        of: currentElement,
                        at: currentIndexPath,
                        ancestors: ancestors + [currentElement]
                    )
                }

                resetCurrentElement()
            }

            while queueIndex < queue.count {
                let queuedElement = queue[queueIndex]
                queueIndex += 1

                if let siblingGroup = queuedElement.siblingGroup,
                   skippedSiblingGroups.contains(siblingGroup)
                {
                    continue
                }

                guard matches(
                    queuedElement.Element,
                    at: queuedElement.indexPath,
                    depth: queuedElement.depth
                ) else {
                    continue
                }

                if queuedElement.depth < minDepth {
                    enqueueChildrenIfNeeded(
                        of: queuedElement.Element,
                        at: queuedElement.indexPath,
                        ancestors: queuedElement.ancestors + [queuedElement.Element]
                    )
                    continue
                }

                currentElement = queuedElement.Element
                currentIndexPath = queuedElement.indexPath
                currentSiblingGroup = queuedElement.siblingGroup

                indexPath = queuedElement.indexPath
                ancestors = queuedElement.ancestors

                compactQueueIfNeeded()

                return queuedElement.Element
            }

            queue.removeAll(keepingCapacity: false)
            queueIndex = 0

            return nil
        }

        private mutating func enqueueChildrenIfNeeded(
            of Element: Element,
            at indexPath: IndexPath,
            ancestors: [Element]
        ) {
            guard indexPath.count < maxDepth,
                  maxChildrenPerElement > 0,
                  let children = children(Element),
                  !children.isEmpty
            else {
                return
            }

            enqueue(
                children,
                parentIndexPath: indexPath,
                depth: indexPath.count + 1,
                ancestors: ancestors
            )
        }

        // MARK: - Filtering

        private mutating func matches(
            _ Element: Element,
            at indexPath: IndexPath,
            depth: Int
        ) -> Bool {
            guard let matchPredicate else {
                return true
            }

            if let cached = matchCache[indexPath] {
                return cached
            }

            // A direct match immediately succeeds. Its descendants aren't inspected.
            if matchPredicate(Element) {
                matchCache[indexPath] = true
                return true
            }

            guard depth < maxDepth,
                  maxChildrenPerElement > 0,
                  let children = children(Element),
                  !children.isEmpty
            else {
                matchCache[indexPath] = false
                return false
            }

            var iterator = makeChildIterator(children)
            var childIndex = 0

            while childIndex < maxChildrenPerElement,
                  let child = iterator.next()
            {
                let childIndexPath = indexPath.appending(childIndex)

                if matches(
                    child,
                    at: childIndexPath,
                    depth: depth + 1
                ) {
                    matchCache[indexPath] = true
                    return true
                }

                childIndex += 1
            }

            matchCache[indexPath] = false
            return false
        }

        // MARK: - Children

        private func makeChildIterator(_ children: Children) -> ChildIterator {
            guard let childComparator else {
                return .collection(children.makeIterator())
            }

            let children = children.sorted(by: childComparator)
            return .array(children.makeIterator())
        }

        // MARK: - Breadth-first queue

        private mutating func enqueue(
            _ children: Children,
            parentIndexPath: IndexPath,
            depth: Int,
            ancestors: [Element]
        ) {
            let siblingGroup = nextSiblingGroup
            nextSiblingGroup += 1

            var iterator = makeChildIterator(children)
            var index = 0

            while index < maxChildrenPerElement,
                  let Element = iterator.next()
            {
                let indexPath = parentIndexPath.appending(index)

                if matches(
                    Element,
                    at: indexPath,
                    depth: depth
                ) {
                    queue.append(
                        QueuedElement(
                            Element: Element,
                            indexPath: indexPath,
                            depth: depth,
                            ancestors: ancestors,
                            siblingGroup: siblingGroup
                        )
                    )
                }

                index += 1
            }
        }

        // MARK: - State

        private mutating func resetCurrentElement() {
            currentElement = nil
            currentIndexPath = IndexPath()
            currentSiblingGroup = nil
            skipsDescendants = false
            skipsRemainingSiblings = false
        }

        private mutating func compactQueueIfNeeded() {
            guard queueIndex > 1024,
                  queueIndex > queue.count / 2
            else {
                return
            }

            queue.removeFirst(queueIndex)
            queueIndex = 0
        }
    }
}

public extension HierarchySequence {
    /// Returns a sequence that provides each Element together with its index path.
    func indexed() -> Indexed {
        Indexed(base: self)
    }

    struct Indexed: Sequence {
        private let base: HierarchySequence

        fileprivate init(base: HierarchySequence) {
            self.base = base
        }

        /// Returns an iterator over the indexed Elements in the hierarchy.
        public func makeIterator() -> Iterator {
            Iterator(base: base.makeIterator())
        }

        public struct Iterator: IteratorProtocol {

            private var base: HierarchySequence.Iterator

            fileprivate init(base: HierarchySequence.Iterator) {
                self.base = base
            }

            /// The depth of the Element most recently returned by `next()`, where the root has a depth of `0`.
            public var depth: Int {
                base.depth
            }

            /// The index of the Element most recently returned by `next()` within its parent's children.
            public var index: Int {
                base.index
            }

            /// The index path of the Element most recently returned by `next()` within the hierarchy.
            public var indexPath: IndexPath {
                base.indexPath
            }

            /// The ancestors of the Element most recently returned by `next()`, ordered from the root to the immediate parent.
            public var ancestors: [Element] {
                base.ancestors
            }

            /// The parent of the Element most recently returned by `next()`, or `nil` if the Element is the root.
            public var parent: Element? {
                base.parent
            }

            /**
             Returns the next indexed Element in the hierarchy.

             After a Element is returned, ``index``, ``depth``, ``indexPath``, ``ancestors``, and
             ``parent`` describe that Element until the next call to `next()`.
             */
            public mutating func next() -> (indexPath: IndexPath, element: Element)? {
                guard let element = base.next() else {
                    return nil
                }

                return (
                    indexPath: base.indexPath,
                    element: element
                )
            }

            /**
             Skips the descendants of the Element most recently returned by `next()`.

             This method has no effect during depth-first postorder traversal because the Element's
             descendants have already been traversed.
             */
            public mutating func skipDescendants() {
                base.skipDescendants()
            }

            /// Skips the remaining siblings of the Element most recently returned by `next()`.
            public mutating func skipRemainingSiblings() {
                base.skipRemainingSiblings()
            }
        }
    }
}
