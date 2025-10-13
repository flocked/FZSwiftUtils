//
//  TimeStamp.swift
//  
//
//  Created by Florian Zand on 03.10.25.
//

import Foundation

/// A timestamp that captures the current absolute time and an optional title.
public struct TimeStamp: Comparable, Hashable {
    /// The absolute time when the timestamp was created.
    public let time = CFAbsoluteTimeGetCurrent()
    /// An descriptive title for the timestamp.
    public let title: String?
    /// The timestamp represented as a `Date`.
    public var date: Date {
        Date(timeIntervalSinceReferenceDate: time)
    }
    
    public init(title: String? = nil) {
        self.title = title
    }
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.time < rhs.time
    }
}

extension Collection where Element == TimeStamp {
    /// The duration between the earliest and latest timestamp in the collection.
    public func timeSpan() -> TimeDuration {
        guard count > 1 else { return .zero }
        let sorted = sorted()
        return TimeDuration(sorted.last!.time - sorted.first!.time)
    }
    
    /// The average interval between consecutive timestamps in the collection.
    public func averageInterval() -> TimeDuration {
        guard count > 1 else { return .zero }
        return TimeDuration(timeSpan().seconds / Double(count - 1))
    }
    
    /// The standard deviation of the intervals between consecutive timestamps.
    public func standardDeviation() -> TimeDuration {
        guard count > 1 else { return .zero }
        let sorted = sorted()
        let intervals = zip(sorted, sorted.dropFirst()).map { $1.time - $0.time }
        let average = intervals.sum() / Double(intervals.count)
        let variance = intervals.reduce(0) { $0 + pow($1 - average, 2) } / Double(intervals.count)
        return TimeDuration(sqrt(variance))
    }
}
