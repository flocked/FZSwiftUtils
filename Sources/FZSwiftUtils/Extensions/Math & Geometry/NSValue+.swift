//
//  File.swift
//  
//
//  Created by Florian Zand on 22.09.23.
//

import Foundation
import QuartzCore

public extension CGPoint {
    var nsValue: NSValue {
        #if os(iOS)
        return NSValue(cgPoint: self)
        #else
        return NSValue(point: NSPointFromCGPoint(self))
        #endif
    }
}

public extension CGRect {
    var nsValue: NSValue {
        #if os(iOS)
        return NSValue(cgRect: self)
        #else
        return NSValue(rect: NSRectFromCGRect(self))
        #endif
    }
}

public extension CGSize {
    var nsValue: NSValue {
        #if os(iOS)
        return NSValue(cgSize: self)
        #else
        return NSValue(size: NSSizeFromCGSize(self))
        #endif
    }
}

public extension NSRange {
    var nsValue: NSValue {
        return NSValue(range: self)
    }
}

public extension ClosedRange where Bound == IntegerLiteralType {
    var nsValue: NSValue {
        return NSValue(range: self.nsRange)
    }
}

public extension Range where Bound == IntegerLiteralType {
    var nsValue: NSValue {
        return NSValue(range: self.nsRange)
    }
}

#if os(macOS)
public extension NSEdgeInsets {
    var nsValue: NSValue {
        return NSValue(edgeInsets: self)
    }
}
#elseif canImport(UIKit)
public extension UIEdgeInsets {
    var nsValue: NSValue {
        return NSValue(uiEdgeInsets: self)
    }
}
#endif

public extension CATransform3D {
    var nsValue: NSValue {
        return NSValue(caTransform3D: self)
    }
}

