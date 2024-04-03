//
//  Progress+.swift
//
//
//  Created by Florian Zand on 01.03.23.
//

import Foundation

public extension Progress {
    /// The identifier of the progress.
    var identifier: Any? {
        get { getAssociatedValue("Progress_identifier", initialValue: nil) }
        set {
            setAssociatedValue(newValue, key: "Progress_identifier")
        }
    }
    
    /// The time interval for calculating the throughput and estimate time remaining via ``updateEstimatedTimeRemaining()``.
    var estimateTimeEvaluationTimeInterval: TimeInterval {
        get { getAssociatedValue("progressSamples", initialValue: 10) }
        set { setAssociatedValue(newValue, key: "progressSamples") }
    }

    /// Updates the estimate time remaining and throughput.
    func updateEstimatedTimeRemaining() {
        refreshThroughputAndEstimatedTimeRemaining()
        
        if !autoUpdateEstimatedTimeRemaining {
            setupEstimatedTimeProgressObserver()
        }
    }
    
    /**
     Updates the estimate time remaining and throughput by providing the start date of the progress.

     - Parameters:
        - date: The start date of the progress.
        - completedUnits: The units completed since start.
     */
    func updateEstimatedTimeRemaining(dateStarted date: Date, completedUnits: Int64? = nil) {
        let elapsedTime = Date().timeIntervalSince(date)
        updateEstimatedTimeRemaining(timeElapsed: elapsedTime, completedUnits: completedUnits)
    }

    /**
     Updates the estimate time remaining and throughput by providing the time elapsed since the start of the progress.

     - Parameters:
        - elapsedTime: The time elapsed since the start of the progress.
        - completedUnits: The units completed since start.
     */
    func updateEstimatedTimeRemaining(timeElapsed elapsedTime: TimeInterval, completedUnits: Int64? = nil) {
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
        
        delayedEstimatedTimeRemainingUpdate?.cancel()
        if autoUpdateEstimatedTimeRemaining, !isCompleted {
            let task = DispatchWorkItem { [weak self] in
                guard let self = self, self.autoUpdateEstimatedTimeRemaining else { return }
                self.updateEstimatedTimeRemaining()
            }
            delayedEstimatedTimeRemainingUpdate = task
            let lastUpdate = TimeDuration(from: lastUpdate, to: Date())
            if lastUpdate.minutes > 10 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 120, execute: task)
            } else if lastUpdate.minutes > 5 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 60, execute: task)
            } else if lastUpdate.minutes > 3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: task)
            } else if lastUpdate.minutes > 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: task)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: task)
            }
        }
    }

    /// A Boolean value indicating whether the progress should auomatically update the estimated time and throughput remaining.
    var autoUpdateEstimatedTimeRemaining: Bool {
        get { getAssociatedValue("Progress_autoUpdateEstimatedTimeRemaining", initialValue: false) }
        set {
            guard newValue != autoUpdateEstimatedTimeRemaining else { return }
            setAssociatedValue(newValue, key: "Progress_autoUpdateEstimatedTimeRemaining")
            setupEstimatedTimeProgressObserver()
        }
    }
    
    internal var delayedEstimatedTimeRemainingUpdate: DispatchWorkItem? {
        get { getAssociatedValue("delayedEstimatedTimeRemainingUpdate", initialValue: nil ) }
        set { setAssociatedValue(newValue, key: "delayedEstimatedTimeRemainingUpdate") }
    }
    
    internal var lastUpdate: Date {
        get { getAssociatedValue("lastUpdate", initialValue: Date() ) }
        set { setAssociatedValue(newValue, key: "lastUpdate") }
    }

    #if os(macOS)
        /**
         The progress will be shown as a progress bar in the Finder for the given url.

         - Parameters:
            -   url: The URL of the file.
            - kind: The kind of the file operation.

         - Warning: Don't call this method if the progress is already published.
         */
        func addFileProgress(url: URL, kind: FileOperationKind = .downloading) {
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
        static func file(url: URL, kind: Progress.FileOperationKind, completed: DataSize? = nil, size: DataSize? = nil) -> Progress {
            let progress = Progress()
            progress.kind = .file
            progress.fileURL = url
            progress.fileOperationKind = kind
            progress.totalUnitCount = Int64(size?.bytes ?? 0)
            progress.completedUnitCount = Int64(completed?.bytes ?? Int(progress.completedUnitCount))
            progress.publish()
            return progress
        }
    #endif

    internal var estimatedTimeProgressObserver: KeyValueObserver<Progress>? {
        get { getAssociatedValue("Progress_estimatedTimeProgressObserver", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "Progress_estimatedTimeProgressObserver") }
    }

    internal var estimatedTimeStartDate: Date {
        get { getAssociatedValue("Progress_estimatedTimeStartDate", initialValue: Date()) }
        set { setAssociatedValue(newValue, key: "Progress_estimatedTimeStartDate") }
    }

    internal var estimatedTimeCompletedUnits: Int64 {
        get { getAssociatedValue("Progress_estimatedTimeCompletedUnits", initialValue: completedUnitCount) }
        set {
            guard estimatedTimeCompletedUnits != newValue else { return }
            setAssociatedValue(newValue, key: "Progress_estimatedTimeCompletedUnits")
        }
    }

    internal var isPublished: Bool {
        get { getAssociatedValue("isPublished", initialValue: false) }
        set {
            setAssociatedValue(newValue, key: "isPublished")
        }
    }

    internal func setupEstimatedTimeProgressObserver() {
        if autoUpdateEstimatedTimeRemaining {
            if estimatedTimeProgressObserver == nil {
                estimatedTimeProgressObserver = KeyValueObserver(self)
                
                estimatedTimeProgressObserver?.add(\.isPaused) { old, new in
                    guard old != new else { return }
                    self.estimatedTimeStartDate = Date()
                    self.estimatedTimeCompletedUnits = self.completedUnitCount
                    self.updateEstimatedTimeRemaining()
                }

                estimatedTimeProgressObserver?.add(\.isCancelled) { old, new in
                    guard old != new else { return }
                    self.updateEstimatedTimeRemaining()
                }

                estimatedTimeProgressObserver?.add(\.fractionCompleted, sendInitalValue: true) { old, new in
                    guard old != new else { return }
                    self.lastUpdate = Date()
                    self.updateEstimatedTimeRemaining()
                }
            }
        } else {
            delayedEstimatedTimeRemainingUpdate?.cancel()
            estimatedTimeProgressObserver = nil
        }
    }
}

extension Progress {
    var progressSamples: [(date: Date, completedUnitCount: Int64)] {
        get { getAssociatedValue("progressSamples", initialValue: []) }
        set { setAssociatedValue(newValue, key: "progressSamples") }
    }
            
    func refreshThroughputAndEstimatedTimeRemaining() {
        let progressSampleLimitTimeInterval: TimeInterval = 10.0
        let progressSampleLimitCount = 30
        
      //  estimateTimeEvaluationTimeInterval
        
        progressSamples.append((Date(), completedUnitCount))
        progressSamples = progressSamples.filter({ $0.date > Date(timeIntervalSinceNow: -progressSampleLimitTimeInterval) }).suffix(progressSampleLimitCount)
        refreshThroughput()
        refreshEstimatedTimeRemaining()
    }
    
    func refreshEstimatedTimeRemaining() {
        let throughputAsDouble = Double(throughput ?? 0)
        guard let completedUnitCount = progressSamples.last?.completedUnitCount, throughputAsDouble != 0 else {
            estimatedTimeRemaining = nil
            return
        }
        let remainingUnitCount = max(0, Int(totalUnitCount - completedUnitCount))
        estimatedTimeRemaining = Double(remainingUnitCount) / throughputAsDouble
    }
    
    func refreshThroughput() {
        guard progressSamples.count > 1 else {
            throughput = 0
            return
        }
        var throughputs = [Int]()
        for index in 0..<progressSamples.count-1 {
            let startSample = progressSamples[index]
            let endSample = progressSamples[index+1]
            let completedUnitCount = max(0, endSample.completedUnitCount - startSample.completedUnitCount)
            let timeInterval = max(Double.leastNonzeroMagnitude, endSample.date.timeIntervalSince(startSample.date))
            throughputs.append(Int(Double(completedUnitCount) / timeInterval))
        }
        guard throughputs.count > 0 else { return }
        throughput = throughputs.reduce(0, +) / throughputs.count
    }
}
