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
        unicodeScalars.contains { $0.properties.isEmojiPresentation || $0.properties.isEmoji }
    }
}
