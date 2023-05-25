//
//  DisplayableEnum.swift
//  DisplayableEnum
//
//  Created by Boinx on 29.08.22.
//

import Foundation

public protocol DisplayableEnum: CaseIterable, Equatable {
    static var count: Int { get }
    static func value(at index: Int) -> Self
    static func index(of value: Self) -> Int
    static func localizedName(at index: Int) -> String
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
