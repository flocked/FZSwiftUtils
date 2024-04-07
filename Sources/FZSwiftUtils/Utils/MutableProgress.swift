//
//  MutableProgress.swift
//
//  Parts taken from:
//  https://gist.github.com/AvdLee/6c7353fab031f11f6c9e47594ee9cfa8
//  Created by Florian Zand on 07.07.23.
//

import Foundation

/// A progress that allows to add and remove children progresses.
open class MutableProgress: Progress {
    
    var isAddingChildren: Bool = false
    var observedChildren = SynchronizedDictionary<Progress, KeyValueObserver<Progress>>()
    
    /// All the current children progresses.
   @objc dynamic open var children: [Progress] {
        get { observedChildren.keys }
        set {
            isAddingChildren = true
            let diff = children.difference(to: newValue)
            diff.removed.forEach { removeChild($0) }
            diff.added.forEach { addChild($0) }
            isAddingChildren = false
        }
    }
    
    /// All the current unfinished children progresses.
    open var unfinishedChildren: [Progress] {
        observedChildren.keys.filter({!$0.isFinished})
    }
    
    /// All the current unfinished children progresses.
    open var finishedChildren: [Progress] {
        observedChildren.keys.filter({$0.isFinished})
    }
    
    /// The progress of all children progresses combined.
    @objc dynamic public let totalProgress = Progress()
    
    /// The progress of all unfinished children progresses combined.
    @objc dynamic public let unfinishedProgress = Progress()
    
    func updateProgresses() {
        let unfinishedChildren = unfinishedChildren
        unfinishedProgress.totalUnitCount = unfinishedChildren.compactMap({$0.totalUnitCount}).sum()
        unfinishedProgress.completedUnitCount = unfinishedChildren.compactMap({$0.completedUnitCount}).sum().clamped(to: 0...unfinishedProgress.totalUnitCount)
        unfinishedProgress.throughput = Int(unfinishedChildren.compactMap({$0.throughput}).average())
        unfinishedProgress.estimatedTimeRemaining = unfinishedChildren.compactMap({$0.estimatedTimeRemaining}).average()
        let children = children
        totalProgress.totalUnitCount = children.compactMap({$0.totalUnitCount}).sum()
        totalProgress.completedUnitCount = children.compactMap({$0.completedUnitCount}).sum().clamped(to: 0...totalProgress.totalUnitCount)
        totalProgress.throughput = Int(children.compactMap({$0.throughput}).average())
        totalProgress.estimatedTimeRemaining = children.compactMap({$0.estimatedTimeRemaining}).average()
    }

    /**
     Adds a new child. Will always use a pending unit count of 1.
     
     - Parameter child: The child to add.
     */
    open func addChild(_ child: Progress) {
        guard observedChildren[child] == nil else { return }
        if !isAddingChildren {
            willChangeValue(for: \.children)
        }
        willChangeValue(for: \.fractionCompleted)
        willChangeValue(for: \.completedUnitCount)
        willChangeValue(for: \.totalUnitCount)
        
        let observer = KeyValueObserver(child)
        observedChildren[child] = observer
        updateProgresses()
        
        observer.add(\.totalUnitCount) { [weak self] _, _ in
            guard let self = self else { return }
            self.updateProgresses()
        }
        
        observer.add(\.completedUnitCount) { [weak self] _, _ in
            guard let self = self else { return }
            self.updateProgresses()
        }
        
        observer.add(\.fractionCompleted) { [weak self] _, _ in
            guard let self = self else { return }
            self.willChangeValue(for: \.fractionCompleted)
            self.didChangeValue(for: \.fractionCompleted)
            self.updateProgresses()
        }

        observer.add(\.isCancelled) { [weak self] _, isCancelled in
            guard let self = self else { return }
            if isCancelled {
                self.removeChild(child)
                self.updateProgresses()
            }
        }
        if !isAddingChildren {
            didChangeValue(for: \.children)
        }
        didChangeValue(for: \.fractionCompleted)
        didChangeValue(for: \.completedUnitCount)
        didChangeValue(for: \.totalUnitCount)
    }

    /**
     Removes the given child from the progress reporting.
     
     - Parameter child: The child to remove.
     */
    open func removeChild(_ child: Progress) {
        guard observedChildren[child] != nil else { return }
        if !isAddingChildren {
            willChangeValue(for: \.children)
        }
        willChangeValue(for: \.fractionCompleted)
        willChangeValue(for: \.completedUnitCount)
        willChangeValue(for: \.totalUnitCount)
        observedChildren[child] = nil
        updateProgresses()
        if !isAddingChildren {
            didChangeValue(for: \.children)
        }
        didChangeValue(for: \.totalUnitCount)
        didChangeValue(for: \.completedUnitCount)
        didChangeValue(for: \.fractionCompleted)
    }

    override open var totalUnitCount: Int64 {
        get { Int64(observedChildren.count) }
        set { }
    }

    override open var completedUnitCount: Int64 {
        get { Int64(children.filter(\.isCompleted).count) }
        set { }
    }
    
    override open var fractionCompleted: Double {
        children.compactMap({$0.fractionCompleted}).average().clamped(max: 100.0)
    }

    override open var userInfo: [ProgressUserInfoKey: Any] {
        var userinfo = super.userInfo
        let unfinishedChildren = unfinishedChildren
        if unfinishedChildren.count == 0 {
            userinfo[.throughputKey] = 0
            userinfo[.estimatedTimeRemainingKey] = 0.0
            return userinfo
        }
        let throughputs = unfinishedChildren.compactMap({$0.throughput})
        if !throughputs.isEmpty {
            userinfo[.throughputKey] = Int(throughputs.average())
        }
        let estimatedTimeRemainings = unfinishedChildren.compactMap({$0.estimatedTimeRemaining})
        if !estimatedTimeRemainings.isEmpty {
            userinfo[.estimatedTimeRemainingKey] = estimatedTimeRemainings.average()
        }
        return userinfo
    }

    override public func addChild(_ child: Progress, withPendingUnitCount inUnitCount: Int64) {
        assert(inUnitCount == 1, "Unit count is ignored and is fixed to 1 for MutableProgress")
        addChild(child)
    }
}
