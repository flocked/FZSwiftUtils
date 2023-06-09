//
//  MutableProgress.swift
//  
//  Parts taken from:
//  https://gist.github.com/AvdLee/6c7353fab031f11f6c9e47594ee9cfa8
//  Created by Florian Zand on 07.07.23.
//

import Foundation

/// A progress that allows to add and remove children progresses.
public final class MutableProgress: Progress {
    
    /// All the current tracked children.
    public var children: [Progress] {
        get { Array(self.observedChildren.keys) }
        set {
            let currentChilds = self.children
            currentChilds.filter({ newValue.contains($0) == false }).forEach({ self.removeChild($0) })
            newValue.filter({ currentChilds.contains($0) == false }).forEach({ self.addChild($0) })
        }
    }

    /// All the current tracked children and their observers.
    private var observedChildren: [Progress: KeyValueObserver<Progress>] = [:]

    /// Adds a new child. Will always use a pending unit count of 1.
    ///
    /// - Parameter child: The child to add.
    public func addChild(_ child: Progress) {
        willChangeValue(for: \.totalUnitCount)
        let observer = KeyValueObserver(child)
        observedChildren[child] = observer
        observer.add(\.fractionCompleted, sendInitalValue: true) {  [weak self] old, new in
            self?.willChangeValue(for: \.fractionCompleted)
            self?.didChangeValue(for: \.fractionCompleted)

            if child.isCompleted {
                self?.willChangeValue(for: \.completedUnitCount)
                self?.didChangeValue(for: \.completedUnitCount)
            } else if child.isCancelled {
                self?.removeChild(child)
            }
        }
        
        observer.add(\.isCancelled) {  [weak self] old, new in
            if new == true {
                self?.removeChild(child)
            }
        }

        didChangeValue(for: \.totalUnitCount)
    }

    /// Removes the given child from the progress reporting.
    ///
    /// - Parameter child: The child to remove.
    public func removeChild(_ child: Progress) {
        willChangeValue(for: \.fractionCompleted)
        willChangeValue(for: \.completedUnitCount)
        willChangeValue(for: \.totalUnitCount)
        observedChildren[child] = nil
        didChangeValue(for: \.totalUnitCount)
        didChangeValue(for: \.completedUnitCount)
        didChangeValue(for: \.fractionCompleted)
    }
    
    public override var totalUnitCount: Int64 {
        get {
            return Int64(observedChildren.count)
        }
        set {
            fatalError("Setting the total unit count is not supported for MutableProgress")
        }
    }

    public override var completedUnitCount: Int64 {
        get {
            return Int64(observedChildren.filter { $0.key.isCompleted }.count)
        }
        set {
            fatalError("Setting the completed unit count is not supported for MutableProgress")
        }
    }

    public override var fractionCompleted: Double {
        return observedChildren.map { $0.key.fractionCompleted }.reduce(0, +) / Double(totalUnitCount)
    }

    // MARK: Overriding methods to make sure this class is used correctly.
    public override func addChild(_ child: Progress, withPendingUnitCount inUnitCount: Int64) {
        assert(inUnitCount == 1, "Unit count is ignored and is fixed to 1 for MutableProgress")
        addChild(child)
    }
}

public extension Progress {
    var isCompleted: Bool {
        guard totalUnitCount > 0 else { return true }
        return completedUnitCount >= totalUnitCount
    }
}
