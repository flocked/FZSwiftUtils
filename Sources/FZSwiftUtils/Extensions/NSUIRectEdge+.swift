//
//  NSUIRectEdge+.swift
//
//
//  Created by Florian Zand on 15.12.23.
//

import Foundation
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension NSUIRectEdge: Hashable, Codable {
    /// The left and right edge of the rectangle.
    public static let width: NSUIRectEdge = [.left, .right]
    /// The bottom and top edge of the rectangle.
    public static let height: NSUIRectEdge = [.bottom, .top]
}

extension NSDirectionalRectEdge: Hashable, Codable {
    /// The leading and trailing edge of the rectangle.
    public static let width: NSDirectionalRectEdge = [.leading, .trailing]
    /// The bottom and top edge of the rectangle.
    public static let height: NSDirectionalRectEdge = [.bottom, .top]
}
