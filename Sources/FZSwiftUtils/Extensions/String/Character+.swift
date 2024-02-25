//
//  Character+.swift
//  
//
//  Created by Florian Zand on 25.02.24.
//

import Foundation

extension Character {
    /// A Boolean value indicating whether the character is an emoji character.
    public var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmoji && (scalar.value > 0x238C || unicodeScalars.count > 1)
    }
}
