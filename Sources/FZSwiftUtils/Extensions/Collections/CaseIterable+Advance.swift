//
//  CaseIterable+Advance.swift
//  
//
//  Created by Florian Zand on 30.08.23.
//

import Foundation

extension CaseIterable where Self: Hashable {
    /// Returns the next case from `Self.allCases` or `nil` if there isn´t a next case.
    var nextCase: Self? {
        let allCases = Self.allCases
        if let index = allCases.firstIndex(of: self) {
            let nextIndex = allCases.index(after: index)
            if nextIndex != allCases.endIndex {
                return allCases[nextIndex]
            }
        }
        return nil
    }
    
    /// Returns the next case from `Self.allCases` or `nil` if there isn´t a next case. If the current case is the last case, it returns the first case.
    var nextCaseLooping: Self? {
        let allCases = Self.allCases
        if let index = allCases.firstIndex(of: self) {
            let nextIndex = allCases.index(after: index)
            if nextIndex == allCases.endIndex {
                return allCases[allCases.startIndex]
            } else {
                return allCases[nextIndex]
            }
        }
        return nil
    }
    
    /// Returns the previous case from `Self.allCases` or `nil` if there isn´t a previous case.
    var previousCase: Self? {
        let allCases = Self.allCases
        if let index = allCases.firstIndex(of: self) {
            if index != allCases.startIndex {
                let previousIndex = allCases.index(index, offsetBy: -1)
                return allCases[previousIndex]
            }
        }
        return nil
    }
    
    /// Returns the previous case from `Self.allCases` or `nil` if there isn´t a previous case. If the current case is the first case, it returns the last case.
    var previousCaseLooping: Self? {
        let allCases = Self.allCases
        if let index = allCases.firstIndex(of: self) {
            if index == allCases.startIndex {
                let previousIndex = allCases.index(allCases.endIndex, offsetBy: -1)
                return allCases[previousIndex]
            } else {
                let previousIndex = allCases.index(index, offsetBy: -1)
                return allCases[previousIndex]
            }
        }
        return nil
    }
}
