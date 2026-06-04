//
//  Displayable.swift
//
//
//  Created by Boinx on 29.08.22.
//

import Foundation

/// A protocol that provides an automatic data source for `CaseIterable` types in user interfaces like table views.
public protocol Displayable: CaseIterable, Equatable {
    /// Returns the number of possible values.
    static var count: Int { get }
    /// Returns the value at the given index.
    static func value(at index: Int) -> Self
    /// Returns the index of a given value.
    static func index(of value: Self) -> Int
    /// Returns the localized name at the given index.
    static func localizedName(at index: Int) -> String
    /// Returns the localized name of the value.
    var localizedName: String { get }
}

public extension Displayable {
    static var count: Int {
        allCases.count
    }

    static func value(at index: Int) -> Self {
        Array(allCases)[index]
    }

    static func index(of value: Self) -> Int {
        Array(allCases).firstIndex(of: value)!
    }

    static func localizedName(at index: Int) -> String {
        value(at: index).localizedName
    }

    @_disfavoredOverload
    var localizedName: String {
       getEnumCaseName(for: self) ?? "\(self)"
    }
}

public extension Displayable where Self: RawRepresentable, RawValue == String {
    var localizedName: String {
        rawValue
    }
}

public extension Displayable where Self: CustomStringConvertible {
    var localizedName: String {
        description
    }
}

public extension Displayable where Self: RawRepresentable, RawValue == String, Self: CustomStringConvertible {
    var localizedName: String {
        rawValue
    }
}
