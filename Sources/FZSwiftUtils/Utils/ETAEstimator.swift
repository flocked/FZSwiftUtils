//
//  ETAEstimator.swift
//
//
//  Created by Florian Zand on 09.05.26.
//

import Foundation

/// Estimates time remaining from recent progress samples.
public struct ETAEstimator {
    /// A time remaining estimate and its supporting rate data.
    public struct ETA {
        /// The estimated time remaining.
        public let duration: TimeDuration

        /// The estimated units completed per second.
        public let estimatedUnitsPerSecond: Double

        /// The estimate confidence from `0` to `1`.
        public let confidence: Double
    }

    private struct Sample {
        let date: Date
        let remaining: DataSize
    }

    private var samples: [Sample] = []
    private var previousETASeconds: TimeInterval?
    private var previousUnitsPerSecond: Double?

    /// The maximum age of samples used for estimates.
    public var maxSampleAge: TimeDuration

    /// The smoothing factor used for rate and ETA changes.
    public var smoothing: Double {
        didSet { smoothing = smoothing.clamped(to: 0...1) }
    }

    /// The maximum fractional ETA change allowed between estimates.
    public var maxETAChangeRatio: Double {
        didSet { maxETAChangeRatio = max(0, maxETAChangeRatio) }
    }

    /// The maximum fractional rate change allowed between estimates.
    public var maxRateChangeRatio: Double {
        didSet { maxRateChangeRatio = max(0, maxRateChangeRatio) }
    }

    /// A Boolean value indicating whether increasing remaining work resets the estimator.
    public var resetOnProgressIncrease: Bool = true

    /// Creates an ETA estimator.
    public init(
        maxSampleAge: TimeDuration = .seconds(30),
        smoothing: Double = 0.35,
        maxETAChangeRatio: Double = 0.35,
        maxRateChangeRatio: Double = 0.5,
        resetOnProgressIncrease: Bool = true
    ) {
        self.maxSampleAge = maxSampleAge
        self.smoothing = smoothing
        self.maxETAChangeRatio = maxETAChangeRatio
        self.maxRateChangeRatio = maxRateChangeRatio
        self.resetOnProgressIncrease = resetOnProgressIncrease
    }

    /// Removes all samples and previous estimates.
    public mutating func reset() {
        samples.removeAll()
        previousETASeconds = nil
        previousUnitsPerSecond = nil
    }

    /// Adds a remaining-work sample at the current time.
    public mutating func addSample(remaining: DataSize) {
        let date: Date = Date()
        guard remaining >= 0 else { return }
        if resetOnProgressIncrease,
           let last = samples.last,
           remaining > last.remaining {
            reset()
        }
        samples.append(Sample(date: date, remaining: remaining))
        pruneSamples(relativeTo: date, maxSampleAge: maxSampleAge.seconds)
    }

    /// Returns the current ETA estimate, or `nil` when there is not enough valid progress data.
    public mutating func estimate(remaining currentUnitsLeft: DataSize? = nil) -> ETA? {
        let now = samples.last?.date ?? Date()
        pruneSamples(relativeTo: now, maxSampleAge: maxSampleAge.seconds)

        let remaining = currentUnitsLeft ?? samples.last?.remaining ?? 0

        guard remaining > 0 else {
            previousETASeconds = 0
            previousUnitsPerSecond = 0
            return ETA(duration: .zero, estimatedUnitsPerSecond: 0, confidence: 1)
        }

        guard samples.count >= 2 else { return nil }

        let rates = zip(samples, samples.dropFirst()).compactMap { previous, current -> Double? in
            let elapsed = current.date.timeIntervalSince(previous.date)
            let transferred = previous.remaining.bytes - current.remaining.bytes

            guard elapsed > 0, transferred > 0 else {
                return nil
            }

            let rate = Double(transferred) / elapsed
            return rate.isFinite && rate > 0 ? rate : nil
        }

        guard !rates.isEmpty else { return nil }

        let filteredRates = rates.removingOutliers()
        guard !filteredRates.isEmpty else { return nil }

        let alpha = smoothing.clamped(to: 0...1)

        let rawUnitsPerSecond = filteredRates.exponentialMovingAverage(smoothing: alpha)

        let estimatedUnitsPerSecond = rawUnitsPerSecond.hybridSmoothed(relativeTo: previousUnitsPerSecond, alpha: alpha, maxChangeRatio: maxRateChangeRatio)

        guard estimatedUnitsPerSecond > 0, estimatedUnitsPerSecond.isFinite else {
            return nil
        }

        let rawETA = Double(remaining.bytes) / estimatedUnitsPerSecond

        let eta = rawETA.hybridSmoothed(relativeTo: previousETASeconds, alpha: alpha, maxChangeRatio: maxETAChangeRatio)

        guard eta.isFinite, eta >= 0 else { return nil }

        previousETASeconds = eta
        previousUnitsPerSecond = estimatedUnitsPerSecond

        let confidence = filteredRates.stabilityScore()

        return ETA(duration: .seconds(eta), estimatedUnitsPerSecond: estimatedUnitsPerSecond, confidence: confidence)
    }

    private mutating func pruneSamples(relativeTo date: Date, maxSampleAge: TimeInterval) {
        guard maxSampleAge > 0 else {
            samples.removeAll()
            return
        }
        samples.removeAll {
            date.timeIntervalSince($0.date) > maxSampleAge
        }
    }
}

fileprivate extension Collection where Element == Double {
    func exponentialMovingAverage(smoothing alpha: Double) -> Double {
        guard var result = first else { return 0 }
        
        let alpha = alpha.clamped(to: 0...1)
        
        for value in dropFirst() {
            result = alpha * value + (1 - alpha) * result
        }
        
        return result
    }
}

