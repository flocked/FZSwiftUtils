//
//  Progress+.swift
//
//
//  Created by Florian Zand on 01.03.23.
//

import Foundation

extension Progress {
    
    /// The identifier of the progress.
    public var identifier: Any? {
        get { getAssociatedValue("identifier", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "identifier") }
    }
    
    /// The estimate time remaining.
    public var estimateDurationRemaining: TimeDuration? {
        guard let seconds = estimatedTimeRemaining else { return nil }
        return TimeDuration(seconds)
    }

    /// Updates the estimate time remaining and throughput.
    public func updateEstimatedTimeRemaining() {
        let changed = completedUnitCount - (progressSamples.last?.completed ?? completedUnitCount)
        progressSamples.append((Date(), changed, completedUnitCount))
        progressSamples = progressSamples.filter({ $0.date > Date(timeIntervalSinceNow: -estimateTimeEvaluationTimeInterval) }).suffix(progressSampleLimitCount)
        throughput = Int(progressSamples.compactMap({$0.changed}).average())
        refreshEstimatedTimeRemaining()
        
        delayedEstimatedTimeRemainingUpdate?.cancel()
        if autoUpdateEstimatedTimeRemaining, !isCompleted, !isPaused, !isCancelled, estimateTimeUpdateCount != maxEstimateTimeUpdateCount {
            let delay = estimateTimeEvaluationTimeInterval*(1.0/Double(maxEstimateTimeUpdateCount))
            delayedEstimatedTimeRemainingUpdate = DispatchWorkItem { [weak self] in
                guard let self = self, self.autoUpdateEstimatedTimeRemaining else { return }
                self.estimateTimeUpdateCount += 1
                self.updateEstimatedTimeRemaining()
            }.perform(after: delay)
        }
    }
    
    func refreshEstimatedTimeRemaining() {
        guard !isCompleted else {
            estimatedTimeRemaining = 0
            return
        }
        let throughput = Double(throughput ?? 0)
        guard let completedUnitCount = progressSamples.last?.completed, throughput != 0 else {
            estimatedTimeRemaining = nil
            return
        }
        let remainingUnitCount = max(0, Int(totalUnitCount - completedUnitCount))
        estimatedTimeRemaining = Double(remainingUnitCount) / throughput
    }
    
    /**
     Updates the estimate time remaining and throughput by providing the start date of the progress.

     - Parameters:
        - date: The start date of the progress.
        - completedUnits: The units completed since start.
     */
    public func updateEstimatedTimeRemaining(dateStarted date: Date, completedUnits: Int64? = nil) {
        let elapsedTime = Date().timeIntervalSince(date)
        updateEstimatedTimeRemaining(timeElapsed: elapsedTime, completedUnits: completedUnits)
    }

    /**
     Updates the estimate time remaining and throughput by providing the time elapsed since the start of the progress.

     - Parameters:
        - elapsedTime: The time elapsed since the start of the progress.
        - completedUnits: The units completed since start.
     */
    public func updateEstimatedTimeRemaining(timeElapsed elapsedTime: TimeInterval, completedUnits: Int64? = nil) {
        guard Int64(elapsedTime) > 1 else {
            self.throughput = 0
            estimatedTimeRemaining = TimeInterval.infinity
            return
        }

        guard self.completedUnitCount != self.totalUnitCount else {
            self.throughput = 0
            estimatedTimeRemaining = 0.0
            return
        }
        estimatedTimeCompletedUnits = completedUnits ?? estimatedTimeCompletedUnits
        var completedUnitCount = completedUnitCount - estimatedTimeCompletedUnits
        var totalUnitCount = totalUnitCount - (completedUnits ?? 0)

        if completedUnitCount < 0 {
            completedUnitCount = 0
        }
        if totalUnitCount < 0 {
            totalUnitCount = 0
        }

        let unitsPerSecond = Double(completedUnitCount) / elapsedTime
        let throughput = Int(unitsPerSecond)
        let unitsRemaining = totalUnitCount - completedUnitCount

        guard unitsPerSecond > 0 else {
            self.throughput = throughput
            estimatedTimeRemaining = TimeInterval.infinity
            return
        }

        let secondsRemaining = Double(unitsRemaining) / unitsPerSecond

        self.throughput = throughput
        estimatedTimeRemaining = secondsRemaining
    }

    /// A Boolean value indicating whether the progress should auomatically update the estimated time remaining and throughput.
    public var autoUpdateEstimatedTimeRemaining: Bool {
        get { estimatedTimeProgressObserver != nil }
        set {
            guard newValue != autoUpdateEstimatedTimeRemaining else { return }
            if newValue {
                estimateTimeUpdateCount = 0
                estimatedTimeProgressObserver = KeyValueObserver(self)
                estimatedTimeProgressObserver?.add(\.isPaused) { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.estimateTimeUpdateCount = 0
                    self.updateEstimatedTimeRemaining()
                }
                estimatedTimeProgressObserver?.add(\.isCancelled) { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.estimateTimeUpdateCount = 0
                    self.updateEstimatedTimeRemaining()
                }
                estimatedTimeProgressObserver?.add(\.fractionCompleted, sendInitalValue: true) { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.estimateTimeUpdateCount = 0
                    self.updateEstimatedTimeRemaining()
                }
            } else {
                delayedEstimatedTimeRemainingUpdate?.cancel()
                estimatedTimeProgressObserver = nil
            }
        }
    }
    
    /// The time interval for calculating the throughput and estimate time remaining via ``updateEstimatedTimeRemaining()``.
    public var estimateTimeEvaluationTimeInterval: TimeInterval {
        get { getAssociatedValue("estimateTimeInterval", initialValue: 30) }
        set { setAssociatedValue(newValue.clamped(min: 0.1), key: "estimateTimeInterval") }
    }
    
    var estimatedTimeStartDate: Date {
        get { getAssociatedValue("estimatedTimeStartDate", initialValue: Date()) }
        set { setAssociatedValue(newValue, key: "estimatedTimeStartDate") }
    }

    var estimatedTimeCompletedUnits: Int64 {
        get { getAssociatedValue("estimatedTimeCompletedUnits", initialValue: completedUnitCount) }
        set { setAssociatedValue(newValue, key: "estimatedTimeCompletedUnits")  }
    }
    
    var estimatedTimeProgressObserver: KeyValueObserver<Progress>? {
        get { getAssociatedValue("estimatedTimeProgressObserver", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "estimatedTimeProgressObserver") }
    }
    
    var delayedEstimatedTimeRemainingUpdate: DispatchWorkItem? {
        get { getAssociatedValue("delayedEstimatedTimeRemainingUpdate", initialValue: nil ) }
        set { setAssociatedValue(newValue, key: "delayedEstimatedTimeRemainingUpdate") }
    }
    
    /// etaSamples, delayedETAUpdate, etaSampleLimitCount
    var progressSamples: [(date: Date, changed: Int64, completed: Int64)] {
        get { getAssociatedValue("progressSamples", initialValue: []) }
        set { setAssociatedValue(newValue, key: "progressSamples") }
    }
    
    /// The maximum amount of samples.
    var progressSampleLimitCount: Int {
        30
    }
    
    var estimateTimeUpdateCount: Int {
        get { getAssociatedValue("estimateTimeUpdateCount", initialValue: 0) }
        set { setAssociatedValue(newValue, key: "estimateTimeUpdateCount") }
    }
    
    var maxEstimateTimeUpdateCount: Int {
        4
    }
    
    var isCompleted: Bool {
        guard totalUnitCount > 0 else { return false }
        return completedUnitCount >= totalUnitCount
    }

    #if os(macOS)
        /**
         The progress will be shown as a progress bar in the Finder for the given url.

         - Parameters:
            -   url: The URL of the file.
            - kind: The kind of the file operation.

         - Warning: Don't call this method if the progress is already published.
         */
        public func addFileProgress(url: URL, kind: FileOperationKind = .downloading) {
            guard fileURL != url else { return }
            fileURL = url
            fileOperationKind = kind
            self.kind = .file
            if isPublished == false {
                publish()
                isPublished = true
            }
        }

        /**
         Creates a file progress.

         A file progress will show a progress bar in the Finder. If `cancellationHandler` is provided, the user will be able to cancel the progress. If `pauseHandler` is provided, the user will be able to pause the progress.

         - Parameters:
            - url: The URL of the file.
            - kind: The kind of the file operation.
            - size: The size of the file in `DataSize` format.
            - pauseHandler: The block to invoke when pausing progress. If a handler is provided, the progress will be pausable.
            - cancellationHandler: he block to invoke when canceling progress. If a handler is provided, the progress will be cancellable.

         - Returns: A `Progress` object representing the file progress.
         */
        public static func file(url: URL, kind: Progress.FileOperationKind, completed: DataSize? = nil, size: DataSize? = nil) -> Progress {
            let progress = Progress()
            progress.kind = .file
            progress.fileURL = url
            progress.fileOperationKind = kind
            progress.totalUnitCount = Int64(size?.bytes ?? 0)
            progress.completedUnitCount = Int64(completed?.bytes ?? Int(progress.completedUnitCount))
            progress.publish()
            return progress
        }
    
    var isPublished: Bool {
        get { getAssociatedValue("isPublished", initialValue: false) }
        set { setAssociatedValue(newValue, key: "isPublished") }
    }
    #endif
}
