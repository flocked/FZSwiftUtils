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
        getValue(&insets)
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
    
    /// Creates a new value object containing the specified CoreGraphics vector structure.
    convenience init(cgVector: CGVector) {
        var transform = cgVector
        self.init(bytes: &transform, objCType: _getObjCTypeEncoding(CGVector.self))
    }

    /// Returns the CoreGraphics vector structure representation of the value.
    var cgVectorValue: CGVector {
        var transform = CGVector.zero
        getValue(&transform)
        return transform
    }
}

#endif

public extension CGPoint {
    /// A `NSValue` representation of the value.
    var nsValue: NSValue {
        #if canImport(UIKit) || os(watchOS)
        NSValue(cgPoint: self)
        #else
        NSValue(point: self)
        #endif
    }
}

public extension CGRect {
    /// A `NSValue` representation of the value.
    var nsValue: NSValue {
        #if canImport(UIKit) || os(watchOS)
        NSValue(cgRect: self)
        #else
        NSValue(rect: self)
        #endif
    }
}

public extension CGSize {
    /// A `NSValue` representation of the value.
    var nsValue: NSValue {
        #if canImport(UIKit) || os(watchOS)
        NSValue(cgSize: self)
        #else
        NSValue(size: self)
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

public extension CGAffineTransform {
    /// A `NSValue` representation of the value.
    var nsValue: NSValue {
        NSValue(cgAffineTransform: self)
    }
}

public extension NSDirectionalEdgeInsets {
    /// A `NSValue` representation of the value.
    var nsValue: NSValue {
        NSValue(directionalEdgeInsets: self)
    }
}

public extension CGVector {
    /// A `NSValue` representation of the value.
    var nsValue: NSValue {
        NSValue(cgVector: self)
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
