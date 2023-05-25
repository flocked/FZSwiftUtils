//
//  File.swift
//  
//
//  Created by Florian Zand on 01.03.23.
//

import Foundation

public extension Progress {
    func estimatedTimeRemaining(dateStarted: Date) {
        let elapsedTime = Date().timeIntervalSince(dateStarted)
        self.estimatedTimeRemaining(timeElapsed: elapsedTime)
    }
    
    func estimatedTimeRemaining(timeElapsed elapsedTime: TimeInterval) {
        guard Int64(elapsedTime) > 1 else {
            self.setUserInfoObject(0, forKey: .throughputKey)
            self.setUserInfoObject(TimeInterval.infinity, forKey: .estimatedTimeRemainingKey)
            return
        }
        let unitsPerSecond = self.completedUnitCount.quotientAndRemainder(dividingBy: Int64(elapsedTime)).quotient
        let throughput = Int(unitsPerSecond)
        let unitsRemaining = self.totalUnitCount - self.completedUnitCount
        let secondsRemaining = unitsRemaining.quotientAndRemainder(dividingBy: Int64(throughput)).quotient
        self.setUserInfoObject(throughput, forKey: .throughputKey)
        guard throughput > 0 else {
            self.setUserInfoObject(TimeInterval.infinity, forKey: .estimatedTimeRemainingKey)
            return
        }
        self.estimatedTimeRemaining = TimeInterval(secondsRemaining)
    }
}
