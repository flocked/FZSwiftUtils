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
    
    /// The time interval for calculating the throughput and estimate time remaining via ``updateEstimatedTimeRemaining()``.
    public var estimateTimeEvaluationTimeInterval: TimeInterval {
        get { getAssociatedValue("estimateTimeInterval", initialValue: 20) }
        set { setAssociatedValue(newValue.clamped(min: 0.1), key: "estimateTimeInterval") }
    }

    /// Updates the estimate time remaining and throughput.
    public func updateEstimatedTimeRemaining() {
        let progressSampleLimitCount = 30
        progressSamples.append((Date(), completedUnitCount))
        progressSamples = progressSamples.filter({ $0.date > Date(timeIntervalSinceNow: -estimateTimeEvaluationTimeInterval) }).suffix(progressSampleLimitCount)
        refreshThroughput()
        refreshEstimatedTimeRemaining()
        
        delayedEstimatedTimeRemainingUpdate?.cancel()
        if autoUpdateEstimatedTimeRemaining, !isCompleted, !isPaused, !isCancelled {
            let task = DispatchWorkItem { [weak self] in
                guard let self = self, self.autoUpdateEstimatedTimeRemaining else { return }
                self.updateEstimatedTimeRemaining()
            }
            delayedEstimatedTimeRemainingUpdate = task
            DispatchQueue.main.asyncAfter(deadline: .now() + estimateTimeEvaluationTimeInterval*0.33, execute: task)
        }
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

    /// A Boolean value indicating whether the progress should auomatically update the estimated time and throughput remaining.
    public var autoUpdateEstimatedTimeRemaining: Bool {
        get { getAssociatedValue("autoUpdateEstimatedTimeRemaining", initialValue: false) }
        set {
            guard newValue != autoUpdateEstimatedTimeRemaining else { return }
            setAssociatedValue(newValue, key: "autoUpdateEstimatedTimeRemaining")
            if newValue {
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
            } else {
                delayedEstimatedTimeRemainingUpdate?.cancel()
                estimatedTimeProgressObserver = nil
            }
        }
    }
    
    var delayedEstimatedTimeRemainingUpdate: DispatchWorkItem? {
        get { getAssociatedValue("delayedEstimatedTimeRemainingUpdate", initialValue: nil ) }
        set { setAssociatedValue(newValue, key: "delayedEstimatedTimeRemainingUpdate") }
    }
    
    var lastUpdate: Date {
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

    var estimatedTimeProgressObserver: KeyValueObserver<Progress>? {
        get { getAssociatedValue("estimatedTimeProgressObserver", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "estimatedTimeProgressObserver") }
    }

    var estimatedTimeStartDate: Date {
        get { getAssociatedValue("estimatedTimeStartDate", initialValue: Date()) }
        set { setAssociatedValue(newValue, key: "estimatedTimeStartDate") }
    }

    var estimatedTimeCompletedUnits: Int64 {
        get { getAssociatedValue("estimatedTimeCompletedUnits", initialValue: completedUnitCount) }
        set { setAssociatedValue(newValue, key: "estimatedTimeCompletedUnits")  }
    }
    
    var progressSamples: [(date: Date, completedUnitCount: Int64)] {
        get { getAssociatedValue("progressSamples", initialValue: []) }
        set { setAssociatedValue(newValue, key: "progressSamples") }
    }
    
    func refreshEstimatedTimeRemaining() {
        guard !isCompleted else {
            estimatedTimeRemaining = 0
            return
        }
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
        //    throughputs.append(Int(Double(completedUnitCount) / timeInterval))
            throughputs.append(Int(completedUnitCount))
        }
        guard throughputs.count > 0 else { return }
        throughput = Int(throughputs.average())
        Swift.print("throughputs", Int(throughputs.average()), (throughputs.reduce(0, +) / throughputs.count))
      //  throughput = throughputs.reduce(0, +) / throughputs.count

    }
    
    var isCompleted: Bool {
        guard totalUnitCount > 0 else { return false }
        return completedUnitCount >= totalUnitCount
    }
}
