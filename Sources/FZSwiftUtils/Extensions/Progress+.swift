//
//  Progress+.swift
//
//
//  Created by Florian Zand on 01.03.23.
//

import Foundation

public extension Progress {    
    /**
     Updates the estimate time remaining by providing the start date of the progress.
     
     - Parameters:
     - date: The start date of the progress.
     */
    func updateEstimatedTimeRemaining(dateStarted date: Date) {
        let elapsedTime = Date().timeIntervalSince(date)
        updateEstimatedTimeRemaining(timeElapsed: elapsedTime)
    }
        
    /**
     Updates the estimate time remaining by providing the time elapsed since the start of the progress.
     
     - Parameters:
     - elapsedTime: The time elapsed since the start of the progress.
     */
    func updateEstimatedTimeRemaining(timeElapsed elapsedTime: TimeInterval) {
        guard Int64(elapsedTime) > 1 else {
            self.throughput = 0
            self.estimatedTimeRemaining = TimeInterval.infinity
            return
        }
        
        let unitsPerSecond = completedUnitCount.quotientAndRemainder(dividingBy: Int64(elapsedTime)).quotient
        let throughput = Int(unitsPerSecond)
        let unitsRemaining = totalUnitCount - completedUnitCount
        
        guard throughput > 0 else {
            self.estimatedTimeRemaining = TimeInterval.infinity
            return
        }
        
        let secondsRemaining = unitsRemaining.quotientAndRemainder(dividingBy: Int64(throughput)).quotient
        
        self.throughput = throughput
        self.estimatedTimeRemaining = TimeInterval(secondsRemaining)
    }
    
    /**
     A boolean value indicating whether the progress should auomatically update the estimated time remaining.
     */
    var autoUpdateEstimatedTimeRemaining: Bool {
        get { getAssociatedValue(key: "Progress_autoUpdateEstimatedTimeRemaining", object: self, initialValue: false) }
        set {
            guard newValue != autoUpdateEstimatedTimeRemaining else { return }
            set(associatedValue: newValue, key: "Progress_autoUpdateEstimatedTimeRemaining", object: self)
            self.setupEstimatedTimeProgressObserver()
        }
    }
    
    /**
     The progress will be shown as a progress bar in the Finder for the given url.
     
     - Parameters:
     - url: The URL of the file.
     - kind: The kind of the file operation.
     */
    func addFileProgress(url: URL, kind: FileOperationKind) {
        guard self.fileProgress?.userInfo[.fileURLKey] as? URL != url else { return }
        self.fileProgress = .file(url: url, kind: kind)
        self.fileProgress?.observeValues(of: self)
    }
    
    /// Removes reflecting the file progress.
    func removeFileProgress() {
        self.fileProgress?.cancel()
        self.fileProgress = nil
    }
    
    internal var fileProgress: Progress? {
        get { getAssociatedValue(key: "Progress_fileProgress", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "Progress_fileProgress", object: self) }
    }
    
    internal var progressObserver: KeyValueObserver<Progress>? {
        get { getAssociatedValue(key: "Progress_progressObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "Progress_progressObserver", object: self) }
    }
        
    internal func observeValues(of progress: Progress?) {
        if let progress = progress {
            progressObserver = KeyValueObserver(progress)
            progressObserver?.add(\.fractionCompleted, sendInitalValue: true) { [weak self] old, new in
                guard let self = self, old != new else { return }
                self.totalUnitCount = progress.totalUnitCount
                self.completedUnitCount = progress.completedUnitCount
                self.throughput = progress.throughput
                self.estimatedTimeRemaining = progress.estimatedTimeRemaining
            }
            progressObserver?.add(\.isPaused, sendInitalValue: true) { [weak self] old, isPaused in
                guard let self = self, old != isPaused else { return }
                if isPaused, self.isPaused == false {
                    self.pause()
                } else if isPaused == false, self.isPaused {
                    self.resume()
                }
            }
            progressObserver?.add(\.isCancelled, sendInitalValue: true) { [weak self] _, isCancelled in
                guard let self = self, isCancelled == true, self.isCancelled == false else { return }
                self.cancel()
            }
        } else {
            progressObserver = nil
        }
    }
        
    internal var estimatedTimeProgressObserver: KeyValueObserver<Progress>? {
        get { getAssociatedValue(key: "Progress_estimatedTimeProgressObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "Progress_estimatedTimeProgressObserver", object: self) }
    }
    
    internal var estimatedTimeStartDate: Date {
        get { getAssociatedValue(key: "Progress_estimatedTimeStartDate", object: self, initialValue: Date()) }
        set { set(associatedValue: newValue, key: "Progress_estimatedTimeStartDate", object: self) }
    }
    
    internal func setupEstimatedTimeProgressObserver() {
        if autoUpdateEstimatedTimeRemaining {
            guard estimatedTimeProgressObserver == nil else { return }
            estimatedTimeStartDate = Date()
            estimatedTimeProgressObserver = KeyValueObserver(self)
            estimatedTimeProgressObserver?.add(\.fractionCompleted, sendInitalValue: true) { old, new in
                guard old != new else { return }
                self.updateEstimatedTimeRemaining()
            }
  
            estimatedTimeProgressObserver?.add(\.isPaused) { old, new in
                guard old != new else { return }
                self.estimatedTimeStartDate = Date()
                self.updateEstimatedTimeRemaining()
            }
            
            estimatedTimeProgressObserver?.add(\.isCancelled) { old, new in
                guard old != new else { return }
                self.updateEstimatedTimeRemaining()
            }
            
            self.updateEstimatedTimeRemaining()
            
        } else {
            estimatedTimeProgressObserver = nil
        }
    }
    
    internal func updateEstimatedTimeRemaining() {
        guard self.autoUpdateEstimatedTimeRemaining, self.isCancelled == false && self.isPaused == false else {
            self.estimatedTimeRemaining = TimeInterval.infinity
            self.throughput = 0
            return
        }
        self.updateEstimatedTimeRemaining(dateStarted: self.estimatedTimeStartDate)
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
    static func file(url: URL, kind: Progress.FileOperationKind, size: DataSize? = nil, pauseHandler: (()->())? = nil, cancellationHandler: (()->())? = nil) -> Progress {
        let progress = Progress(parent: nil, userInfo: [
            .fileOperationKindKey: kind,
            .fileURLKey: url,
        ])
        progress.kind = .file
        progress.isPausable = (pauseHandler != nil)
        progress.isCancellable = (cancellationHandler != nil)
        progress.pausingHandler = pauseHandler
        progress.setUserInfoObject(nil, forKey: .fileURLKey)
        progress.cancellationHandler = cancellationHandler
        progress.totalUnitCount = Int64(size?.bytes ?? 0)
        progress.publish()
        return progress
    }
}

public extension ProgressUserInfoKey {
    /**
     A key with a corresponding value that represents the start date of the progress.
     */
    static let startedDateKey = ProgressUserInfoKey("startedDate")
}
