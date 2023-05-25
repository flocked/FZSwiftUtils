//
//  AttributedString+.swift
//
//
//  Created by Florian Zand on 30.03.23.
//

import Foundation

@available(macOS 12, iOS 15.0, *)
public extension AttributedString {
    func lowercased() -> AttributedString {
        return AttributedString(NSAttributedString(self).lowercased())
    }

    func uppercased() -> AttributedString {
        return AttributedString(NSAttributedString(self).uppercased())
    }

    func capitalized() -> AttributedString {
        return AttributedString(NSAttributedString(self).capitalized())
    }
}
