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
        get { getAssociatedValue("identifier") }
        set { setAssociatedValue(newValue, key: "identifier") }
    }
    
    /// The estimate time remaining.
    public var estimateDurationRemaining: TimeDuration? {
        guard let seconds = estimatedTimeRemaining else { return nil }
        return TimeDuration(seconds)
    }

    /// Updates the estimate time remaining and throughput.
    public func updateEstimatedTimeRemaining() {
        eta.addSample(completedUnitCount)
        throughput = isCancelled ? nil : isFinished ? 0 : Int(eta.samples.compactMap({$0.changed}).weightedAverage())
        estimatedTimeRemaining = isCancelled ? nil : isFinished || throughput == 0 ? 0 : Double(totalUnitCount - completedUnitCount) / Double(throughput ?? 0)
        
        eta.delayedUpdate?.cancel()
        if autoUpdateEstimatedTimeRemaining, !isFinished, !isCancelled, eta.count != eta.maxCount {
            eta.delayedUpdate = DispatchWorkItem { [weak self] in
                guard let self = self, self.autoUpdateEstimatedTimeRemaining else { return }
                self.eta.count += 1
                self.updateEstimatedTimeRemaining()
            }.perform(after: 4.0)
        }
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
     Updates the estimate time remaining and throughput by providing the completed unit and time elapsed since the start of the progress.

     - Parameters:
        - timeElapsed: The time elapsed since the start of the progress.
        - completedUnits: The units completed since the start of the progress.
     */
    public func updateEstimatedTimeRemaining(timeElapsed: TimeInterval, completedUnits: Int64) {
        throughput = isCancelled ? nil : isFinished || timeElapsed <= 0 ? 0 : Int(Double(completedUnits) / timeElapsed)
        estimatedTimeRemaining = isCancelled ? nil : isFinished || throughput == 0 ? 0 : Double(totalUnitCount - completedUnitCount) / Double(throughput ?? 0)
    }

    /// A Boolean value indicating whether the progress should auomatically update the estimated time remaining and throughput.
    public var autoUpdateEstimatedTimeRemaining: Bool {
        get { eta.observer != nil }
        set {
            guard newValue != autoUpdateEstimatedTimeRemaining else { return }
            if newValue {
                eta.count = 0
                eta.observer = KeyValueObserver(self)
                eta.observer?.add(\.isPaused) { [weak self] old, new in
                    guard let self = self else { return }
                    self.eta.count = 0
                    self.updateEstimatedTimeRemaining()
                }
                eta.observer?.add(\.isCancelled) { [weak self] old, new in
                    guard let self = self else { return }
                    self.eta.count = 0
                    self.updateEstimatedTimeRemaining()
                }
                eta.observer?.add(\.fractionCompleted, sendInitalValue: true) { [weak self] old, new in
                    guard let self = self else { return }
                    self.eta.count = 0
                    self.updateEstimatedTimeRemaining()
                }
            } else {
                eta.delayedUpdate?.cancel()
                eta.observer = nil
            }
        }
    }

    /// The time interval for calculating the estimate time remaining and throughput via ``updateEstimatedTimeRemaining()``.
    public var estimateTimeEvaluationTimeInterval: TimeInterval {
        get { eta.sampleEvaluationTimeInterval }
        set { eta.sampleEvaluationTimeInterval = newValue }
    }
    
    var eta: ETA {
        get { getAssociatedValue("ETA", initialValue: ETA()) }
        set { setAssociatedValue(newValue, key: "ETA") }
    }
    
    struct ETA {
        var samples: [(date: Date, completed: Int64, changed: Int64)] = []
        let sampleLimit = 30
        var sampleEvaluationTimeInterval: TimeInterval = 30
        var delayedUpdate: DispatchWorkItem?
        var observer: KeyValueObserver<Progress>?
        var count = 0
        let maxCount = 30
        
        mutating func addSample(_ completed: Int64) {
            samples += (Date(), completed, completed - (samples.last?.completed ?? completed))
            samples = samples.filter({ $0.date > Date(timeIntervalSinceNow: -sampleEvaluationTimeInterval) }).suffix(sampleLimit)
        }
    }
    
    #if os(macOS)
        /**
         The progress will be shown as a progress bar in the Finder for the specified file url.

         - Parameters:
            -   url: The URL of the file.
            - kind: The file operation kind.
         */
        public func addFileProgress(url: URL, kind: FileOperationKind = .downloading) {
            guard fileURL != url, !isFinished, !isCancelled else { return }
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
    
    /// Sets the number of completed units of work for the current job.
    @discardableResult
    public func completedUnitCount(_ count: Int64) -> Self {
        completedUnitCount = count
        return self
    }
    
    /// Sets the total number of tracked units of work for the current progress.
    @discardableResult
    public func totalUnitCount(_ count: Int64) -> Self {
        totalUnitCount = count
        return self
    }
    
    /// Sets the fraction of the work that the progress has completed.
    @discardableResult
    public func fractionCompleted(_ value: Double) -> Self {
        completedUnitCount = Int64(value.clamped(max: 1.0) * Double(totalUnitCount))
        return self
    }
    
    /**
     Returns a localized string for the estimate time remaining.
     
     - Parameters:
        - locale: The locale to use.
        - units: The style to use when formatting the quantity or the name of the unit, such as `“1 day ago”` or `“one day ago”`.
        - style: The style to use when describing a relative date, for example `“yesterday”` or `“1 day ago”`.
     */
    public func estimateTimeString(locale: Locale = .current, units: RelativeDateTimeFormatter.UnitsStyle = .full, style: RelativeDateTimeFormatter.DateTimeStyle = .numeric) -> String? {
        guard let estimate = estimateDurationRemaining else { return nil }
        return RelativeDateTimeFormatter().unitsStyle(units).dateTimeStyle(style).locale(locale).localizedString(forTimeDuration: estimate)
    }
    
    /**
     Returns a string for the throughput.
     
     - Parameters:
        - locale: The locale to use.
        - units: The allowed units to be used for formatting.
        - fractionLength: The allowed number of digits after the decimal separator.
     */
    public func throughputString(locale: Locale = .current, units: ThroughputFormatter.Units = .all, fractionLength: NumberFormatter.DigitLength = .max(2)) -> String {
        throughputFormatter.locale = locale
        throughputFormatter.units = units
        throughputFormatter.fractionLength = fractionLength
        return throughputFormatter.string(for: throughput ?? 0)
    }
    
    internal var throughputFormatter: ThroughputFormatter {
        getAssociatedValue("throughputFormatter", initialValue: ThroughputFormatter())
    }
}
