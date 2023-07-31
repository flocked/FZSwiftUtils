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
            diff.removed.forEach({ self.removeChild($0) })
            diff.added.forEach({ self.addChild($0) })
        }
    }
    
    internal lazy var _progressState = ProgressState()
    @objc public dynamic var progressState: ProgressState {
        get { self._progressState }
        set { }
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
        observer.add(\.fractionCompleted, sendInitalValue: true) {  [weak self] old, new in
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
        
        observer.add(\.isCancelled) {  [weak self] old, new in
            guard let self = self else { return }
            if new == true {
                self.removeChild(child)
            }
        }
        
        didChangeValue(for: \.totalUnitCount)
    }
    
    internal func updateProgressState() {
        self.willChangeValue(for: \.progressState)
        self.willChangeValue(for: \.progressState.unfinished)
        let unfinished = self.children.filter({$0.isFinished == false})

        self.progressState._completedUnitCount = self.children.compactMap({$0.completedUnitCount}).sum()
        self.progressState._totalUnitCount = self.children.compactMap({$0.totalUnitCount}).sum()
        self.progressState._fractionCompleted = self.fractionCompleted
        self.progressState.unfinished._completedUnitCount = unfinished.compactMap({$0.completedUnitCount}).sum()
        self.progressState.unfinished._totalUnitCount = unfinished.compactMap({$0.totalUnitCount}).sum()
        self.progressState.unfinished._fractionCompleted = Double(self.progressState.unfinished.completedUnitCount) / Double(self.progressState.unfinished.totalUnitCount)
        
        let timeRemainings = unfinished.compactMap({$0.estimatedTimeRemaining})
        let timeRemaining = timeRemainings.sum()
        self.progressState.estimatedTimeRemaining = timeRemaining
        if timeRemainings.isEmpty == false {
            self.progressState.estimatedTimeRemaining = timeRemainings.sum()
            self.estimatedTimeRemaining = timeRemainings.sum()
        } else {
            self.progressState.estimatedTimeRemaining = 0
            self.estimatedTimeRemaining = nil
        }
        
        let throughputs = unfinished.compactMap({$0.throughput})
        let throughput = throughputs.sum()
        progressState.throughput = throughput
        if throughputs.isEmpty == false {
            self.throughput = throughputs.sum()
        } else {
            self.throughput = nil
        }
        self.didChangeValue(for: \.progressState)
        self.didChangeValue(for: \.progressState.unfinished)
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
    
    public override var totalUnitCount: Int64 {
        get {
            return Int64(observedChildren.count)
        }
        set { }
    }

    public override var completedUnitCount: Int64 {
        get {
            return Int64(self.children.filter { $0.isCompleted }.count)
        }
        set { }
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

public extension MutableProgress {
    class ProgressState: NSObject {
        internal var _completedUnitCount: Int64 = 0 {
            didSet {
                guard oldValue != _completedUnitCount else { return }
                self.completedUnitCount = _completedUnitCount}
        }
        
        internal var _totalUnitCount: Int64 = 0 {
            didSet {
                guard oldValue != _totalUnitCount else { return }
                self.totalUnitCount = _totalUnitCount}
        }
        
        internal var _fractionCompleted: Double = 0 {
            didSet {
                guard oldValue != _fractionCompleted else { return }
                self.fractionCompleted = _fractionCompleted}
        }
        
        internal var _throughput: Int = 0 {
            didSet {
                guard oldValue != _throughput else { return }
                self.throughput = _throughput}
        }
        
        internal var _estimatedTimeRemaining: Double = 0 {
            didSet {
                guard oldValue != _estimatedTimeRemaining else { return }
                self.estimatedTimeRemaining = _estimatedTimeRemaining }
        }

        @objc public dynamic fileprivate(set) var completedUnitCount: Int64 = 0
        
        
        @objc public dynamic fileprivate(set) var totalUnitCount: Int64 = 0
        
        @objc public dynamic fileprivate(set) var fractionCompleted: Double = 0
        
        @objc public dynamic fileprivate(set) var throughput: Int = 0
        
        @objc public dynamic fileprivate(set) var estimatedTimeRemaining: Double = 0
        
        @objc public dynamic fileprivate(set) var unfinished = UnfinishedProgressState()

        public class UnfinishedProgressState: NSObject {
            internal var _completedUnitCount: Int64 = 0 {
                didSet {
                    guard oldValue != _completedUnitCount else { return }
                    self.completedUnitCount = _completedUnitCount}
            }
            
            internal var _totalUnitCount: Int64 = 0 {
                didSet {
                    guard oldValue != _totalUnitCount else { return }
                    self.totalUnitCount = _totalUnitCount}
            }
            
            internal var _fractionCompleted: Double = 0 {
                didSet {
                    guard oldValue != _fractionCompleted else { return }
                    self.fractionCompleted = _fractionCompleted}
            }
            
            @objc public dynamic fileprivate(set) var fractionCompleted: Double = 0
            @objc public dynamic fileprivate(set) var totalUnitCount: Int64 = 0
            @objc public dynamic fileprivate(set) var completedUnitCount: Int64 = 0
        }
    }
}

internal extension Progress {
    var isCompleted: Bool {
        guard totalUnitCount > 0 else { return false }
        return completedUnitCount >= totalUnitCount
    }
}
