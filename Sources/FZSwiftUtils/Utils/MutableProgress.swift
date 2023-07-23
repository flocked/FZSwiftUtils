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
        get { self.observedChildren.keys }
        set {
            let diff = self.children.difference(to: newValue)
            diff.removed.forEach({ self.removeChild($0) })
            diff.added.forEach({ self.addChild($0) })
        }
    }

    /// All the current tracked children and their observers.
    private var observedChildren = SynchronizedDictionary<Progress, KeyValueObserver<Progress>>()

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
                
        observer.add(\.estimatedTimeRemaining) {  [weak self] old, new in
            guard let self = self, old != new else { return }
            let timeRemainings = self.children.compactMap({$0.estimatedTimeRemaining})
            if timeRemainings.isEmpty == false {
                self.estimatedTimeRemaining = timeRemainings.average()
            } else {
                self.estimatedTimeRemaining = nil
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
            return Int64(self.children.filter { $0.isCompleted }.count)
        }
        set {
            fatalError("Setting the completed unit count is not supported for MutableProgress")
        }
    }
    
    public override var userInfo: [ProgressUserInfoKey : Any] {
        get {
            var userinfo = super.userInfo
            userinfo[.throughputKey] = self.children.compactMap({$0.throughput}).sum()
            return userinfo
        }
    }

    public override var fractionCompleted: Double {
        return self.children.map { $0.fractionCompleted }.reduce(0, +) / Double(totalUnitCount)
    }

    // MARK: Overriding methods to make sure this class is used correctly.
    public override func addChild(_ child: Progress, withPendingUnitCount inUnitCount: Int64) {
        assert(inUnitCount == 1, "Unit count is ignored and is fixed to 1 for MutableProgress")
        addChild(child)
    }
}

internal extension Progress {
    var isCompleted: Bool {
        guard totalUnitCount > 0 else { return false }
        return completedUnitCount >= totalUnitCount
    }
}
