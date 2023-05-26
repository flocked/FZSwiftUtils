//
//  File.swift
//
//
//  Created by Florian Zand on 01.03.23.
//

import Foundation

public extension Progress {
    /// Updates the estimate time remaining by providing the start date of the progress.
    func updateEstimatedTimeRemaining(dateStarted: Date) {
        let elapsedTime = Date().timeIntervalSince(dateStarted)
        updateEstimatedTimeRemaining(timeElapsed: elapsedTime)
    }

    /// Updates the estimate time remaining by providing the time elapsed since start of the progress.
    func updateEstimatedTimeRemaining(timeElapsed elapsedTime: TimeInterval) {
        guard Int64(elapsedTime) > 1 else {
            setUserInfoObject(0, forKey: .throughputKey)
            setUserInfoObject(TimeInterval.infinity, forKey: .estimatedTimeRemainingKey)
            return
        }
        let unitsPerSecond = completedUnitCount.quotientAndRemainder(dividingBy: Int64(elapsedTime)).quotient
        let throughput = Int(unitsPerSecond)
        let unitsRemaining = totalUnitCount - completedUnitCount
        let secondsRemaining = unitsRemaining.quotientAndRemainder(dividingBy: Int64(throughput)).quotient
        setUserInfoObject(throughput, forKey: .throughputKey)
        guard throughput > 0 else {
            setUserInfoObject(TimeInterval.infinity, forKey: .estimatedTimeRemainingKey)
            return
        }
        estimatedTimeRemaining = TimeInterval(secondsRemaining)
    }

    /**
     Creates a file progress.

     - Parameters url: The url of the file.
     - Parameters kind: The kind of the process.

     - Returns The finder file progress.

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
