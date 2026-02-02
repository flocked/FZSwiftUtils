//
//  CFString+.swift
//
//
//  Created by Florian Zand on 02.02.26.
//

import Foundation

extension CFString {
    /// The Core Foundation string as `String`.
    public var string: String { self as String }
}
