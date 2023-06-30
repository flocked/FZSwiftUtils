//
//  DisplayableEnum.swift
//  DisplayableEnum
//
//  Created by Boinx on 29.08.22.
//

import Foundation

/// A protocol that provides an automatic data source for enums in user interfaces like tableviews
public protocol DisplayableEnum: CaseIterable, Equatable {
    /// Returns the number of possible values
    static var count: Int { get }
    /// Returns the value at the given index
    static func value(at index: Int) -> Self
    // Returns the index of a given value
    static func index(of value: Self) -> Int
    /// Returns the localized name at the given index
    static func localizedName(at index: Int) -> String
    /// Returns a localized name of the value
    var localizedName: String { get }
}

public extension DisplayableEnum {
    static var count: Int {
        return allCases.count
    }

    static func value(at index: Int) -> Self {
        return Array(allCases)[index]
    }

    static func index(of value: Self) -> Int {
        return Array(allCases).firstIndex(of: value)!
    }

    static func localizedName(at index: Int) -> String {
        return value(at: index).localizedName
    }

    var localizedName: String {
        return "\(self)"
    }
}
