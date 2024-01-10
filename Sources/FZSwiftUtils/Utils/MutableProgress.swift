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
    /// All the current children progresses.
    public var children: [Progress] {
        get { self.observedChildren.keys }
        set {
            let diff = self.children.difference(to: newValue)
            diff.removed.forEach { self.removeChild($0) }
            diff.added.forEach { self.addChild($0) }
        }
    }

    lazy var _progressState = ProgressState()
    @objc public dynamic var progressState: ProgressState {
        get { _progressState }
        set {}
    }

    /// All the current tracked children progresses and their observers.
    private var observedChildren = SynchronizedDictionary<Progress, KeyValueObserver<Progress>>()

    /// Adds a new child. Will always use a pending unit count of 1.
    ///
    /// - Parameter child: The child to add.
    open func addChild(_ child: Progress) {
        willChangeValue(for: \.totalUnitCount)
        let observer = KeyValueObserver(child)
        observedChildren[child] = observer
        observer.add(\.fractionCompleted, sendInitalValue: true) { [weak self] _, _ in
            guard let self = self else { return }
            self.willChangeValue(for: \.fractionCompleted)
            self.didChangeValue(for: \.fractionCompleted)
            self.updateProgressState()
            if child.isCompleted {
                self.willChangeValue(for: \.completedUnitCount)
                self.didChangeValue(for: \.completedUnitCount)
            } else if child.isCancelled {
                self.removeChild(child)
            }
        }

        observer.add(\.isCancelled) { [weak self] _, new in
            guard let self = self else { return }
            if new == true {
                self.removeChild(child)
            }
        }

        didChangeValue(for: \.totalUnitCount)
    }

    func updateProgressState() {
        willChangeValue(for: \.progressState)
        willChangeValue(for: \.progressState.unfinished)
        let unfinished = children.filter { $0.isFinished == false }

        progressState._completedUnitCount = children.compactMap(\.completedUnitCount).sum()
        progressState._totalUnitCount = children.compactMap(\.totalUnitCount).sum()
        progressState._fractionCompleted = fractionCompleted
        progressState.unfinished._completedUnitCount = unfinished.compactMap(\.completedUnitCount).sum()
        progressState.unfinished._totalUnitCount = unfinished.compactMap(\.totalUnitCount).sum()
        progressState.unfinished._fractionCompleted = Double(progressState.unfinished.completedUnitCount) / Double(progressState.unfinished.totalUnitCount)

        let timeRemainings = unfinished.compactMap(\.estimatedTimeRemaining)
        let timeRemaining = timeRemainings.sum()
        progressState.estimatedTimeRemaining = timeRemaining
        if timeRemainings.isEmpty == false {
            progressState.estimatedTimeRemaining = timeRemainings.sum()
            estimatedTimeRemaining = timeRemainings.sum()
        } else {
            progressState.estimatedTimeRemaining = 0
            estimatedTimeRemaining = nil
        }

        let throughputs = unfinished.compactMap(\.throughput)
        let throughput = throughputs.sum()
        progressState.throughput = throughput
        if throughputs.isEmpty == false {
            self.throughput = throughputs.sum()
        } else {
            self.throughput = nil
        }
        didChangeValue(for: \.progressState)
        didChangeValue(for: \.progressState.unfinished)
    }

    /// Removes the given child from the progress reporting.
    ///
    /// - Parameter child: The child to remove.
    public func removeChild(_ child: Progress) {
        willChangeValue(for: \.fractionCompleted)
        willChangeValue(for: \.completedUnitCount)
        willChangeValue(for: \.totalUnitCount)
        observedChildren[child] = nil
        updateProgressState()
        didChangeValue(for: \.totalUnitCount)
        didChangeValue(for: \.completedUnitCount)
        didChangeValue(for: \.fractionCompleted)
    }

    override public var totalUnitCount: Int64 {
        get {
            Int64(observedChildren.count)
        }
        set {}
    }

    override public var completedUnitCount: Int64 {
        get {
            Int64(self.children.filter(\.isCompleted).count)
        }
        set {}
    }

    override public var userInfo: [ProgressUserInfoKey: Any] {
        var userinfo = super.userInfo
        userinfo[.throughputKey] = self.children.compactMap(\.throughput).sum()
        return userinfo
    }

    override public var fractionCompleted: Double {
        self.children.map(\.fractionCompleted).reduce(0, +) / Double(totalUnitCount)
    }

    // MARK: Overriding methods to make sure this class is used correctly.

    override public func addChild(_ child: Progress, withPendingUnitCount inUnitCount: Int64) {
        assert(inUnitCount == 1, "Unit count is ignored and is fixed to 1 for MutableProgress")
        addChild(child)
    }
}

public extension MutableProgress {
    class ProgressState: NSObject {
        var _completedUnitCount: Int64 = 0 {
            didSet {
                guard oldValue != _completedUnitCount else { return }
                completedUnitCount = _completedUnitCount
            }
        }

        var _totalUnitCount: Int64 = 0 {
            didSet {
                guard oldValue != _totalUnitCount else { return }
                totalUnitCount = _totalUnitCount
            }
        }

        var _fractionCompleted: Double = 0 {
            didSet {
                guard oldValue != _fractionCompleted else { return }
                fractionCompleted = _fractionCompleted
            }
        }

        var _throughput: Int = 0 {
            didSet {
                guard oldValue != _throughput else { return }
                throughput = _throughput
            }
        }

        var _estimatedTimeRemaining: Double = 0 {
            didSet {
                guard oldValue != _estimatedTimeRemaining else { return }
                estimatedTimeRemaining = _estimatedTimeRemaining
            }
        }

        @objc public fileprivate(set) dynamic var completedUnitCount: Int64 = 0

        @objc public fileprivate(set) dynamic var totalUnitCount: Int64 = 0

        @objc public fileprivate(set) dynamic var fractionCompleted: Double = 0

        @objc public fileprivate(set) dynamic var throughput: Int = 0

        @objc public fileprivate(set) dynamic var estimatedTimeRemaining: Double = 0

        @objc public fileprivate(set) dynamic var unfinished = UnfinishedProgressState()

        public class UnfinishedProgressState: NSObject {
            var _completedUnitCount: Int64 = 0 {
                didSet {
                    guard oldValue != _completedUnitCount else { return }
                    completedUnitCount = _completedUnitCount
                }
            }

            var _totalUnitCount: Int64 = 0 {
                didSet {
                    guard oldValue != _totalUnitCount else { return }
                    totalUnitCount = _totalUnitCount
                }
            }

            var _fractionCompleted: Double = 0 {
                didSet {
                    guard oldValue != _fractionCompleted else { return }
                    fractionCompleted = _fractionCompleted
                }
            }

            @objc public fileprivate(set) dynamic var fractionCompleted: Double = 0
            @objc public fileprivate(set) dynamic var totalUnitCount: Int64 = 0
            @objc public fileprivate(set) dynamic var completedUnitCount: Int64 = 0
        }
    }
}

extension Progress {
    var isCompleted: Bool {
        guard totalUnitCount > 0 else { return false }
        return completedUnitCount >= totalUnitCount
    }
}
