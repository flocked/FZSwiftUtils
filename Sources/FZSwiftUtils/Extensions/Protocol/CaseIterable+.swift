//
//  CaseIterable+.swift
//
//
//  Created by Florian Zand on 30.08.23.
//

import Foundation

public extension CaseIterable where Self: Equatable {
    /// Returns the next case from `Self.allCases` or `nil` if there isn´t a next case.
    var nextCase: Self? {
        let allCases = Self.allCases
        guard let index = allCases.firstIndex(of: self) else { return nil }
        let nextIndex = allCases.index(after: index)
        return nextIndex != allCases.endIndex ? allCases[nextIndex] : nil
    }

    /// Returns the next case from `Self.allCases` or `nil` if there isn´t a next case. If the current case is the last case, it returns the first case.
    var nextCaseLooping: Self? {
        let allCases = Self.allCases
        guard let index = allCases.firstIndex(of: self) else { return nil }
        let nextIndex = allCases.index(after: index)
        return allCases[nextIndex == allCases.endIndex ? allCases.startIndex : nextIndex]
    }

    /// Returns the previous case from `Self.allCases` or `nil` if there isn´t a previous case.
    var previousCase: Self? {
        let allCases = Self.allCases
        guard let index = allCases.firstIndex(of: self) else { return nil }
        return index != allCases.startIndex ? allCases[allCases.index(index, offsetBy: -1)] : nil
    }

    /// Returns the previous case from `Self.allCases` or `nil` if there isn´t a previous case. If the current case is the first case, it returns the last case.
    var previousCaseLooping: Self? {
        let allCases = Self.allCases
        guard let index = allCases.firstIndex(of: self) else { return nil }
        return allCases[allCases.index(index == allCases.startIndex ? allCases.endIndex : index, offsetBy: -1)]
    }

    /// Returns a random new case from `Self.allCases`, or `nil` if there isn´t a new random case.
    var randomNewCase: Self? {
        Self.allCases.randomElement(excluding: [self])
    }
}
