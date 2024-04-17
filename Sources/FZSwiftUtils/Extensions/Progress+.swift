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
        throughput = isCompleted ? 0 : Int(progressSamples.compactMap({$0.changed}).average())
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
    
    private func refreshEstimatedTimeRemaining() {
        guard !isCompleted else {
            estimatedTimeRemaining = 0
            return
        }
        let throughput = Double(throughput ?? 0)
        guard !isCancelled, let completedUnitCount = progressSamples.last?.completed, throughput != 0 else {
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
    public func updateEstimatedTimeRemaining(dateStarted date: Date, completedUnits: Int64) {
        let elapsedTime = Date().timeIntervalSince(date)
        updateEstimatedTimeRemaining(timeElapsed: elapsedTime, completedUnits: completedUnits)
    }

    /**
     Updates the estimate time remaining and throughput by providing the time elapsed since the start of the progress.

     - Parameters:
        - elapsedTime: The time elapsed since the start of the progress.
        - completedUnits: The units completed since start.
     */
    public func updateEstimatedTimeRemaining(timeElapsed elapsedTime: TimeInterval, completedUnits: Int64) {
        guard !isCompleted else {
            throughput = 0
            estimatedTimeRemaining = 0.0
            return
        }
        
        guard elapsedTime >= 1 else {
            throughput = 0
            estimatedTimeRemaining = nil
            return
        }
        
        let completedUnitCount = (completedUnitCount - completedUnits).clamped(min: 0)
        let totalUnitCount = (totalUnitCount - completedUnits).clamped(min: 0)
        let unitsPerSecond = Double(completedUnitCount) / elapsedTime
        let unitsRemaining = totalUnitCount - completedUnitCount
        
        throughput = Int(unitsPerSecond)
        estimatedTimeRemaining = unitsPerSecond == 0 ? nil : (Double(unitsRemaining) / unitsPerSecond)
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

    /// The time interval for calculating the estimate time remaining and throughput via ``updateEstimatedTimeRemaining()``.
    public var estimateTimeEvaluationTimeInterval: TimeInterval {
        get { getAssociatedValue("estimateTimeInterval", initialValue: 30) }
        set { setAssociatedValue(newValue.clamped(min: 0.1), key: "estimateTimeInterval") }
    }
    
    private var estimatedTimeProgressObserver: KeyValueObserver<Progress>? {
        get { getAssociatedValue("estimatedTimeProgressObserver", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "estimatedTimeProgressObserver") }
    }
    
    private var delayedEstimatedTimeRemainingUpdate: DispatchWorkItem? {
        get { getAssociatedValue("delayedEstimatedTimeRemainingUpdate", initialValue: nil ) }
        set { setAssociatedValue(newValue, key: "delayedEstimatedTimeRemainingUpdate") }
    }
    
    /// ETA progress samples.
    private var progressSamples: [(date: Date, changed: Int64, completed: Int64)] {
        get { getAssociatedValue("progressSamples", initialValue: []) }
        set { setAssociatedValue(newValue, key: "progressSamples") }
    }
    
    /// The maximum amount of ETA progress samples.
    private var progressSampleLimitCount: Int { 30 }
    
    private var estimateTimeUpdateCount: Int {
        get { getAssociatedValue("estimateTimeUpdateCount", initialValue: 0) }
        set { setAssociatedValue(newValue, key: "estimateTimeUpdateCount") }
    }
    
    private var maxEstimateTimeUpdateCount: Int { 4 }
    
    /// A Boolean value that indicates whether progress is completed.
    var isCompleted: Bool {
        fractionCompleted == 1.0
    }

    #if os(macOS)
        /**
         The progress will be shown as a progress bar in the Finder for the specified file url.

         - Parameters:
            -   url: The URL of the file.
            - kind: The file operation kind.
         */
        public func addFileProgress(url: URL, kind: FileOperationKind = .downloading) {
            guard fileURL != url, !isCompleted, !isCancelled else { return }
            fileURL = url
            fileOperationKind = kind
            self.kind = .file
            if isPublished == false {
                publish()
                isPublished = true
            }
        }

        /**
         Creates a file progress that shows a progress bar in the Finder for the specified file url.

         - Parameters:
            - url: The URL of the file.
            - kind: The file operation kind.
            - completed: The completed size of the file.
            - size: The size of the file.

         - Returns: A `Progress` object representing the file progress.
         */
        public static func file(url: URL, kind: Progress.FileOperationKind, completed: DataSize? = nil, size: DataSize? = nil) -> Progress {
            let progress = Progress()
            progress.totalUnitCount = Int64(size?.bytes ?? 0)
            progress.completedUnitCount = Int64(completed?.bytes ?? 0)
            progress.addFileProgress(url: url, kind: kind)
            return progress
        }
    
    private var isPublished: Bool {
        get { getAssociatedValue("isPublished", initialValue: false) }
        set { setAssociatedValue(newValue, key: "isPublished") }
    }
    #endif
}
