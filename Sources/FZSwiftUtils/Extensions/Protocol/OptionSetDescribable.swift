//
//  OptionSetDescribable.swift
//  
//
//  Created by Florian Zand on 24.03.25.
//

import Foundation

/// An `OptionSet` that provides description listing all elements.
public protocol OptionSetDescribable: OptionSet, CustomStringConvertible where RawValue: BinaryInteger {
    static var allCases: [(Element, String)] { get }
}

extension OptionSetDescribable {
    public var description: String {
        "[\(Self.allCases.compactMap { contains($0.0) ? $0.1 : nil }.joined(separator: ", "))]"
    }
}
