//
//  NSValue+.swift
//
//
//  Created by Florian Zand on 22.09.23.
//

import Foundation
#if canImport(QuartzCore)
    import QuartzCore
#endif

#if os(macOS)
    import AppKit

    public extension NSValue {
        /// Creates a new value object containing the specified directional edge insets structure.
        convenience init(directionalEdgeInsets: NSDirectionalEdgeInsets) {
            var insets = directionalEdgeInsets
            self.init(bytes: &insets, objCType: _getObjCTypeEncoding(NSDirectionalEdgeInsets.self))
        }

        /// Returns the directional edge insets structure representation of the value.
        var directionalEdgeInsetsValue: NSDirectionalEdgeInsets {
            var insets = NSDirectionalEdgeInsets()
            self.getValue(&insets)
            return insets
        }

        /// Creates a new value object containing the specified CoreGraphics affine transform structure.
        convenience init(cgAffineTransform: CGAffineTransform) {
            var transform = cgAffineTransform
            self.init(bytes: &transform, objCType: _getObjCTypeEncoding(CGAffineTransform.self))
        }

        /// Returns the CoreGraphics affine transform representation of the value.
        var cgAffineTransformValue: CGAffineTransform {
            var transform = CGAffineTransform.identity
            getValue(&transform)
            return transform
        }
    }
#endif

public extension CGPoint {
    /// A `NSValue` representation of the value.
    var nsValue: NSValue {
        #if canImport(UIKit) || os(watchOS)
            return NSValue(cgPoint: self)
        #else
            return NSValue(point: NSPointFromCGPoint(self))
        #endif
    }
}

public extension CGRect {
    /// A `NSValue` representation of the value.
    var nsValue: NSValue {
        #if canImport(UIKit) || os(watchOS)
            return NSValue(cgRect: self)
        #else
            return NSValue(rect: NSRectFromCGRect(self))
        #endif
    }
}

public extension CGSize {
    /// A `NSValue` representation of the value.
    var nsValue: NSValue {
        #if canImport(UIKit) || os(watchOS)
            return NSValue(cgSize: self)
        #else
            return NSValue(size: NSSizeFromCGSize(self))
        #endif
    }
}

public extension NSRange {
    /// A `NSValue` representation of the value.
    var nsValue: NSValue {
        NSValue(range: self)
    }
}

public extension ClosedRange where Bound: BinaryInteger {
    /// A `NSValue` representation of the value.
    var nsValue: NSValue {
        NSValue(range: nsRange)
    }
}

public extension Range where Bound: BinaryInteger {
    /// A `NSValue` representation of the value.
    var nsValue: NSValue {
        NSValue(range: nsRange)
    }
}

#if os(macOS)
    public extension NSEdgeInsets {
        /// A `NSValue` representation of the value.
        var nsValue: NSValue {
            NSValue(edgeInsets: self)
        }
    }

#elseif canImport(UIKit) || os(watchOS)
    import UIKit
    public extension UIEdgeInsets {
        /// A `NSValue` representation of the value.
        var nsValue: NSValue {
            NSValue(uiEdgeInsets: self)
        }
    }
#endif

#if os(macOS) || os(iOS) || os(tvOS)
    public extension CATransform3D {
        /// A `NSValue` representation of the value.
        var nsValue: NSValue {
            NSValue(caTransform3D: self)
        }
    }
#endif
