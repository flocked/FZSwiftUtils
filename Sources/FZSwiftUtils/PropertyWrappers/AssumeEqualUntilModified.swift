//
//  AssumeEqualUntilModified.swift
//  
//
//  Created by zwaldowski
//

import Foundation

/// Customizes the behavior of automatically-generated `Equatable` and `Hashable` conformances.
@propertyWrapper
public struct AssumeEqualUntilModified<Wrapped> {

    var modificationCount = 0

    public var wrappedValue: Wrapped {
        didSet {
            modificationCount += 1
        }
    }

    public init(wrappedValue: Wrapped) {
        self.wrappedValue = wrappedValue
    }

}

extension AssumeEqualUntilModified: Hashable {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.modificationCount == 0 && rhs.modificationCount == 0
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(modificationCount)
    }

}

/*
 struct MyConfiguration: Hashable {
     var color: UIColor?
     @AssumeEqualUntilModified var colorTransformer: UIConfigurationColorTransformer?
 }
 */
