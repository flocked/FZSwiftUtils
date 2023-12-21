//
//  IndexPath+.swift
//
//
//  Created by Florian Zand on 21.12.23.
//

import Foundation

extension IndexPath {
    /// An index path with a `item` and `section` value of `0`.
    public static var zero: IndexPath { IndexPath(item: 0, section: 0) }
}
