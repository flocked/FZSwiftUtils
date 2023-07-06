//
//  File.swift
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
            setUserInfoObject(0, forKey: .throughputKey)
            setUserInfoObject(TimeInterval.infinity, forKey: .estimatedTimeRemainingKey)
            return
        }
        
        let unitsPerSecond = completedUnitCount.quotientAndRemainder(dividingBy: Int64(elapsedTime)).quotient
        let throughput = Int(unitsPerSecond)
        let unitsRemaining = totalUnitCount - completedUnitCount
        
        guard throughput > 0 else {
            setUserInfoObject(TimeInterval.infinity, forKey: .estimatedTimeRemainingKey)
            return
        }
        
        let secondsRemaining = unitsRemaining.quotientAndRemainder(dividingBy: Int64(throughput)).quotient
        
        setUserInfoObject(throughput, forKey: .throughputKey)
        setUserInfoObject(TimeInterval(secondsRemaining), forKey: .estimatedTimeRemainingKey)
        estimatedTimeRemaining = TimeInterval(secondsRemaining)
    }
    
    /**
     Creates a file progress.
     
     - Parameters:
        - url: The URL of the file.
        - kind: The kind of the file operation.
        - fileSize: The size of the file in `DataSize` format.
     
     - Returns: A `Progress` object representing the file progress.
     */
    static func file(url: URL, kind: Progress.FileOperationKind, fileSize: DataSize? = nil) -> Progress {
        let progress = Progress(parent: nil, userInfo: [
            .fileOperationKindKey: kind,
            .fileURLKey: url,
        ])
        progress.kind = .file
        progress.totalUnitCount = Int64(fileSize?.bytes ?? 0)
        return progress
    }
}
