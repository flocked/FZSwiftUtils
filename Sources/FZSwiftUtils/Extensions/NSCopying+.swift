//
//  NSCopying+.swift
//
//
//  Created by Florian Zand on 20.01.25.
//

import Foundation

extension NSCopying {
    /// Returns a new instance that’s a copy of the receiver.
    func copyAsSelf() -> Self? {
        copy() as? Self
    }
}
