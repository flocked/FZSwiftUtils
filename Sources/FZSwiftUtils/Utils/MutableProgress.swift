//
//  MutableProgress.swift
//
//  Parts taken from:
//  https://gist.github.com/AvdLee/6c7353fab031f11f6c9e47594ee9cfa8
//  Created by Florian Zand on 07.07.23.
//

import Foundation

/*
/// A progress that allows to add and remove children progresses.
open class MutableProgress: Progress, @unchecked Sendable {
    
    private let observedChildren = SynchronizedValue(OrderedDictionary<Progress, KeyValueObserver<Progress>>())
    private let throttler = Throttler(interval: .seconds(0.05))
    private var updateCount = 0
    private let maxUpdateCount = 30
    private var delayedUpdate: DispatchWorkItem?
    
    /// A Boolean value indicating whether cancelled children should be removed automatically.
    public var removesCancelledChildren = false
    
    /**
    The minimum interval between aggregated child progress updates.
     
     Short values reduce latency at the cost of more CPU.
     */
    public var childUpdateInterval: TimeDuration {
        get { throttler.interval }
        set { throttler.interval = newValue }
    }
    
    /// All the current children progresses.
    @objc dynamic open var children: [Progress] {
        get { observedChildren.value.keys.array }
        set {
            let currentChildren = children
            let newChildren = newValue.uniqued()
            let diff = currentChildren.difference(to: newChildren)
            guard !diff.added.isEmpty || !diff.removed.isEmpty || !diff.changed.isEmpty else { return }
            reportWillChange()
            diff.removed.forEach { removeChild($0, report: false) }
            diff.added.forEach { addChild($0, report: false) }
            observedChildren.withMutableValue { value in
                value = OrderedDictionary(uniqueKeysWithValues: newChildren.compactMap { child in
                    value[child].map { (child, $0) }
                })
            }
            reportChange()
        }
    }
    
    /// All the current unfinished children progresses.
    open var unfinishedChildren: [Progress] {
        children.filter({!$0.isFinished && !$0.isCancelled})
    }
    
    /// All the current finished children progresses.
    open var finishedChildren: [Progress] {
        children.filter({$0.isFinished})
    }
    
    /// The progress of all children progresses combined.
    @objc dynamic public let totalProgress = Progress()
    
    /// The progress of all unfinished children progresses combined.
    @objc dynamic public let unfinishedProgress = Progress()
    
    func _updateProgresses() {
        let unfinished = unfinishedChildren
        unfinishedProgress.totalUnitCount = unfinished.map(\.totalUnitCount).sum()
        unfinishedProgress.completedUnitCount = unfinished.map(\.completedUnitCount).sum()
        unfinishedProgress.updateEstimatedTimeRemaining()

        let children = children
        totalProgress.totalUnitCount = children.map(\.totalUnitCount).sum()
        totalProgress.completedUnitCount = children.map(\.completedUnitCount).sum()
        totalProgress.updateEstimatedTimeRemaining()

        delayedUpdate?.cancel()
        if !children.isEmpty, !isFinished, !isCancelled, updateCount < maxUpdateCount {
            delayedUpdate = DispatchWorkItem { [weak self] in
                guard let self else { return }
                self.updateCount += 1
                self._updateProgresses()
            }.perform(after: 4.0)
        }
    }
    
    private func updateProgresses() {
        throttler { [weak self] in
            self?.updateCount = 0
            self?._updateProgresses()
        }
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
        observedChildren.withMutableValue { value in
            guard value[child] == nil else { return }
            if report {
                reportWillChange()
            }
            let observer = KeyValueObserver(child)
            value[child] = observer
            updateProgresses()
            
            observer.add(\.totalUnitCount) { [weak self] _, _ in
                self?.updateProgresses()
            }
            observer.add(\.completedUnitCount) { [weak self] _, _ in
                self?.updateProgresses()
            }
            observer.addWillChange(\.fractionCompleted) { [weak self] _ in
                self?.willChangeValue(for: \.fractionCompleted)
            }
            observer.add(\.fractionCompleted) { [weak self] _, _ in
                self?.didChangeValue(for: \.fractionCompleted)
            }
            observer.add(\.isCancelled) { [weak self] _, isCancelled in
                guard let self = self, isCancelled, self.removesCancelledChildren else { return }
                self.removeChild(child)
                self.updateProgresses()
            }
            observer.addWillChange(\.isFinished) { [weak self] _ in
                self?.willChangeValue(for: \.completedUnitCount)
            }
            observer.add(\.isFinished) { [weak self] _,_ in
                self?.didChangeValue(for: \.completedUnitCount)
            }
            guard report else { return }
            reportChange()
        }
    }
    
    private func removeChild(_ child: Progress, report: Bool) {
        observedChildren.withMutableValue { value in
            guard value[child] != nil else { return }
            if report {
                reportWillChange()
            }
            value[child] = nil
            updateProgresses()
            guard report else { return }
            reportChange()
        }
    }
    
    private func reportWillChange() {
        willChangeValue(for: \.children)
        willChangeValue(for: \.fractionCompleted)
        willChangeValue(for: \.completedUnitCount)
        willChangeValue(for: \.totalUnitCount)
    }
    
    private func reportChange() {
        didChangeValue(for: \.children)
        didChangeValue(for: \.fractionCompleted)
        didChangeValue(for: \.completedUnitCount)
        didChangeValue(for: \.totalUnitCount)
    }

    override open var totalUnitCount: Int64 {
        get { Int64(children.count) }
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
        userinfo[.throughputKey] = unfinishedProgress.throughput
        userinfo[.estimatedTimeRemainingKey] = unfinishedProgress.estimatedTimeRemaining
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
*/


/// A progress object that aggregates the progress of multiple child progress objects.
open class MutableProgress: Progress, @unchecked Sendable {

    private let observedChildren = SynchronizedValue(OrderedDictionary<Progress, KeyValueObserver<Progress>>())
    private let mutationLock = NSRecursiveLock()
    private let throttler = Throttler(interval: .seconds(0.05))

    // Accessed exclusively on the main thread.
    private var updateCount = 0
    private let maxUpdateCount = 30
    private var delayedUpdate: DispatchWorkItem?

    /// A Boolean value indicating whether cancelled children should be removed automatically.
    public var removesCancelledChildren = false

    /**
     The minimum interval between aggregated child progress updates.

     Short values reduce latency at the cost of more CPU.
     */
    public var childUpdateInterval: TimeDuration {
        get { throttler.interval }
        set { throttler.interval = newValue }
    }

    // MARK: - Children

    /// All the current children progresses.
    @objc dynamic open var children: [Progress] {
        get {
            observedChildren.value.keys.array
        }
        set {
            let newChildren = newValue.uniqued()

            mutationLock.lock()
            defer { mutationLock.unlock() }

            let current = observedChildren.value
            let currentChildren = current.keys.array

            guard currentChildren != newChildren else { return }

            reportWillChange()

            var updated = OrderedDictionary<Progress, KeyValueObserver<Progress>>()

            for child in newChildren {
                if let observer = current[child] {
                    updated[child] = observer
                } else {
                    updated[child] = makeObserver(for: child)
                }
            }

            observedChildren.value = updated

            reportChange()
            updateProgresses()
        }
    }

    /// All the current unfinished children progresses.
    open var unfinishedChildren: [Progress] {
        children.filter { !$0.isFinished && !$0.isCancelled }
    }

    /// All the current finished children progresses.
    open var finishedChildren: [Progress] {
        children.filter(\.isFinished)
    }

    // MARK: - Aggregated Progress

    /// The progress of all children progresses combined.
    @objc dynamic public let totalProgress = Progress()

    /// The progress of all unfinished children progresses combined.
    @objc dynamic public let unfinishedProgress = Progress()

    private func _updateProgresses() {
        let children = children
        let unfinished = children.filter { !$0.isFinished && !$0.isCancelled }

        unfinishedProgress.totalUnitCount = unfinished.map(\.totalUnitCount).sum()
        unfinishedProgress.completedUnitCount = unfinished.map(\.completedUnitCount).sum()
        unfinishedProgress.updateEstimatedTimeRemaining()

        totalProgress.totalUnitCount = children.map(\.totalUnitCount).sum()
        totalProgress.completedUnitCount = children.map(\.completedUnitCount).sum()
        totalProgress.updateEstimatedTimeRemaining()

        delayedUpdate?.cancel()
        delayedUpdate = nil

        if !children.isEmpty,
           !isFinished,
           !isCancelled,
           updateCount < maxUpdateCount {

            let workItem = DispatchWorkItem { [weak self] in
                guard let self else { return }
                self.updateCount += 1
                self._updateProgresses()
            }

            delayedUpdate = workItem

            DispatchQueue.main.asyncAfter(
                deadline: .now() + 4.0,
                execute: workItem
            )
        }
    }

    private func updateProgresses() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            self.throttler { [weak self] in
                guard let self else { return }

                DispatchQueue.main.async {
                    self.updateCount = 0
                    self._updateProgresses()
                }
            }
        }
    }

    // MARK: - Adding and Removing Children

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
        mutationLock.lock()
        defer { mutationLock.unlock() }

        guard observedChildren.withValue({ $0[child] == nil }) else {
            return
        }

        if report {
            reportWillChange()
        }

        let observer = makeObserver(for: child)

        observedChildren.withMutableValue { value in
            value[child] = observer
        }

        if report {
            reportChange()
        }

        updateProgresses()
    }

    private func removeChild(_ child: Progress, report: Bool) {
        mutationLock.lock()
        defer { mutationLock.unlock() }

        guard observedChildren.withValue({ $0[child] != nil }) else {
            return
        }

        if report {
            reportWillChange()
        }

        observedChildren.withMutableValue { value in
            value[child] = nil
        }

        if report {
            reportChange()
        }

        updateProgresses()
    }

    // MARK: - Child Observation

    private func makeObserver(for child: Progress) -> KeyValueObserver<Progress> {
        let observer = KeyValueObserver(child)

        observer.add(\.totalUnitCount) { [weak self] _, _ in
            self?.updateProgresses()
        }

        observer.add(\.completedUnitCount) { [weak self] _, _ in
            self?.updateProgresses()
        }

        observer.addWillChange(\.fractionCompleted) { [weak self] _ in
            self?.willChangeValue(for: \.fractionCompleted)
        }

        observer.add(\.fractionCompleted) { [weak self] _, _ in
            self?.didChangeValue(for: \.fractionCompleted)
        }

        observer.add(\.isCancelled) { [weak self] _, isCancelled in
            guard let self, isCancelled, self.removesCancelledChildren else {
                return
            }

            self.removeChild(child)
            self.updateProgresses()
        }

        observer.addWillChange(\.isFinished) { [weak self] _ in
            self?.willChangeValue(for: \.completedUnitCount)
        }

        observer.add(\.isFinished) { [weak self] _, _ in
            self?.didChangeValue(for: \.completedUnitCount)
        }

        return observer
    }

    // MARK: - KVO

    private func reportWillChange() {
        willChangeValue(for: \.children)
        willChangeValue(for: \.fractionCompleted)
        willChangeValue(for: \.completedUnitCount)
        willChangeValue(for: \.totalUnitCount)
    }

    private func reportChange() {
        didChangeValue(for: \.children)
        didChangeValue(for: \.fractionCompleted)
        didChangeValue(for: \.completedUnitCount)
        didChangeValue(for: \.totalUnitCount)
    }

    // MARK: - Progress Properties

    override open var totalUnitCount: Int64 {
        get { Int64(children.count) }
        set { }
    }

    override open var completedUnitCount: Int64 {
        get { Int64(children.filter(\.isFinished).count) }
        set { }
    }

    override open var fractionCompleted: Double {
        children.compactMap(\.fractionCompleted).average().clamped(max: 1.0)
    }

    override open var userInfo: [ProgressUserInfoKey: Any] {
        var userInfo = super.userInfo
        userInfo[.throughputKey] = unfinishedProgress.throughput
        userInfo[.estimatedTimeRemainingKey] = unfinishedProgress.estimatedTimeRemaining
        return userInfo
    }

    override public func addChild(
        _ child: Progress,
        withPendingUnitCount inUnitCount: Int64
    ) {
        if inUnitCount != 1 {
            debugPrint("Unit count is ignored and is fixed to 1 for MutableProgress")
        }

        addChild(child)
    }

    // MARK: - Cancellation and Pausing

    open override func cancel() {
        children.forEach { $0.cancel() }
        super.cancel()
    }

    open override func pause() {
        children.forEach { $0.pause() }
        super.pause()
    }

    // MARK: - Initialization

    /// Creates a new progress instance.
    public init() {
        super.init(parent: nil)
    }
}
