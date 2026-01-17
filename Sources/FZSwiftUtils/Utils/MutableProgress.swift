//
//  MutableProgress.swift
//
//  Parts taken from:
//  https://gist.github.com/AvdLee/6c7353fab031f11f6c9e47594ee9cfa8
//  Created by Florian Zand on 07.07.23.
//

import Foundation

/// A progress that allows to add and remove children progresses.
open class MutableProgress: Progress, @unchecked Sendable {
    
    private var observedChildren = SynchronizedDictionary<Progress, KeyValueObserver<Progress>>()
    private var childUpdateWorkItem: DispatchWorkItem?
    private var childUpdateDebounceTimer = ElapsedTimer()
    
    /// A Boolean value indicating whether cancelled children should be removed automatically.
    public var removesCancelledChildren = false
    
    /**
     Debounce interval for aggregating updates after child notifications.
     
     Short values reduce latency at the cost of more CPU.
     */
    public var childUpdateDebounceInterval: TimeDuration = .seconds(0.05)
        
    /// All the current children progresses.
    @objc dynamic open var children: [Progress] {
        get { observedChildren.keys }
        set {
            let diff = children.uniqued().difference(to: newValue)
            guard !diff.added.isEmpty || !diff.removed.isEmpty else { return }
            willChangeValue(for: \.fractionCompleted)
            willChangeValue(for: \.completedUnitCount)
            willChangeValue(for: \.totalUnitCount)
            diff.removed.forEach { removeChild($0, report: false) }
            diff.added.forEach { addChild($0, report: false) }
            didChangeValue(for: \.fractionCompleted)
            didChangeValue(for: \.completedUnitCount)
            didChangeValue(for: \.totalUnitCount)
        }
    }
    
    /// All the current unfinished children progresses.
    open var unfinishedChildren: [Progress] {
        observedChildren.keys.filter({!$0.isFinished && !$0.isCancelled})
    }
    
    /// All the current unfinished children progresses.
    open var finishedChildren: [Progress] {
        observedChildren.keys.filter({$0.isFinished})
    }
    
    /// The progress of all children progresses combined.
    @objc dynamic public let totalProgress = Progress()
    
    /// The progress of all unfinished children progresses combined.
    @objc dynamic public let unfinishedProgress = Progress()
    
    private func updateProgresses() {
        childUpdateWorkItem?.cancel()
        childUpdateWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            let unfinished = self.unfinishedChildren
            self.unfinishedProgress.totalUnitCount = unfinished.map({$0.totalUnitCount}).sum()
            self.unfinishedProgress.completedUnitCount = unfinished.map({$0.completedUnitCount}).sum()
            self.unfinishedProgress.throughput = Int(unfinished.compactMap({$0.throughput}).average())
            self.unfinishedProgress.estimatedTimeRemaining = unfinished.compactMap({$0.estimatedTimeRemaining}).average()
            let children = self.children
            self.totalProgress.totalUnitCount = children.map({$0.totalUnitCount}).sum()
            self.totalProgress.completedUnitCount = children.map({$0.completedUnitCount}).sum()
            self.totalProgress.throughput = Int(children.compactMap({$0.throughput}).average())
            self.totalProgress.estimatedTimeRemaining = children.compactMap({$0.estimatedTimeRemaining}).average()
        }.perform(after: childUpdateDebounceTimer.remainingTime(for: childUpdateDebounceInterval))
    }

    /**
     Adds a new child. Will always use a pending unit count of 1.
     
     - Parameter child: The child to add.
     */
    open func addChild(_ child: Progress) {
        addChild(child, report: true)
    }

    /**
     Removes the given child from the progress reporting.
     
     - Parameter child: The child to remove.
     */
    open func removeChild(_ child: Progress) {
        removeChild(child, report: true)
    }
    
    private func addChild(_ child: Progress, report: Bool) {
        guard observedChildren[child] == nil else { return }
        if report {
            willChangeValue(for: \.children)
            willChangeValue(for: \.fractionCompleted)
            willChangeValue(for: \.completedUnitCount)
            willChangeValue(for: \.totalUnitCount)
        }
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
            self.updateProgresses()
            self.willChangeValue(for: \.fractionCompleted)
            self.didChangeValue(for: \.fractionCompleted)
        }

        observer.add(\.isCancelled) { [weak self] _, isCancelled in
            guard let self = self else { return }
            if isCancelled, self.removesCancelledChildren {
                self.removeChild(child)
                self.updateProgresses()
            }
        }
        if report {
            didChangeValue(for: \.children)
            didChangeValue(for: \.fractionCompleted)
            didChangeValue(for: \.completedUnitCount)
            didChangeValue(for: \.totalUnitCount)
        }
    }
    
    private func removeChild(_ child: Progress, report: Bool) {
        guard observedChildren[child] != nil else { return }
        if report {
            willChangeValue(for: \.children)
            willChangeValue(for: \.fractionCompleted)
            willChangeValue(for: \.completedUnitCount)
            willChangeValue(for: \.totalUnitCount)
        }
        observedChildren[child] = nil
        updateProgresses()
        if report {
            didChangeValue(for: \.children)
            didChangeValue(for: \.totalUnitCount)
            didChangeValue(for: \.completedUnitCount)
            didChangeValue(for: \.fractionCompleted)
        }
    }

    override open var totalUnitCount: Int64 {
        get { Int64(observedChildren.count) }
        set { }
    }

    override open var completedUnitCount: Int64 {
        get { Int64(children.filter(\.isFinished).count) }
        set { }
    }
    
    override open var fractionCompleted: Double {
        children.compactMap({$0.fractionCompleted}).average().clamped(max: 1.0)
    }

    override open var userInfo: [ProgressUserInfoKey: Any] {
        var userinfo = super.userInfo
        let unfinished = unfinishedChildren
        userinfo[.throughputKey] = unfinished.compactMap({$0.throughput}).sum()
        userinfo[.estimatedTimeRemainingKey] = unfinished.compactMap({$0.estimatedTimeRemaining}).average()
        return userinfo
    }

    override public func addChild(_ child: Progress, withPendingUnitCount inUnitCount: Int64) {
        if inUnitCount != 1 {
            debugPrint("Unit count is ignored and is fixed to 1 for MutableProgress")
        }
        addChild(child)
    }
    
    open override func cancel() {
        children.forEach({ $0.cancel() })
        super.cancel()
    }
    
    open override func pause() {
        children.forEach({ $0.pause() })
        super.pause()
    }
    
    /// Creates a new progress instance.
    public init() {
        super.init(parent: nil)
    }
}

/*
 class AggreateProgress: Progress, @unchecked Sendable {
     let parent: MutableProgress
     let isUnfinished: Bool
     
     var children: [Progress] {
         isUnfinished ? parent.unfinishedChildren : parent.children
     }
     
     override var completedUnitCount: Int64 {
         get { children.map({$0.completedUnitCount}).sum() }
         set { }
     }
     
     override var totalUnitCount: Int64 {
         get { children.map({$0.totalUnitCount}).sum() }
         set { }
     }
     
     override var userInfo: [ProgressUserInfoKey : Any] {
         get { [.estimatedTimeRemainingKey: children.compactMap({$0.estimatedTimeRemaining}).average(), .throughputKey: Int(children.compactMap({$0.throughput}).average())] }
         set {
             
         }
     }
     
     init(parent: MutableProgress, isUnfinished: Bool = false) {
         self.parent = parent
         self.isUnfinished = isUnfinished
         super.init()
     }
 }
 */
