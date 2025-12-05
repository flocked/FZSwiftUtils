//
//  AffineTransform+.swift
//
//
//  Created by Florian Zand on 05.12.25.
//

import Foundation

#if os(macOS)
public extension CGAffineTransform {
    /// `AffineTransform` representation of the graphics coordinate transformation.
    var affineTransform: AffineTransform {
        .init(m11: a, m12: b, m21: c, m22: d, tX: tx, tY: ty)
    }
    
    /// `NSAffineTransform` representation of the graphics coordinate transformation.
    var nsAffineTransform: NSAffineTransform {
        .init(transform: affineTransform)
    }
}

public extension AffineTransform {
    /// `CGAffineTransform` representation of the graphics coordinate transformation.
    var cgAffineTransform: CGAffineTransform {
        .init(m11, m12, m21, m22, tX, tY)
    }
    
    /// `NSAffineTransform` representation of the graphics coordinate transformation.
    var nsAffineTransform: NSAffineTransform {
        self as NSAffineTransform
    }
}

public extension NSAffineTransform {
    /// `CGAffineTransform` representation of the graphics coordinate transformation.
    var cgAffineTransform: CGAffineTransform {
        .init(transformStruct.m11, transformStruct.m12, transformStruct.m21, transformStruct.m22, transformStruct.tX, transformStruct.tY)
    }
    
    /// `AffineTransform` representation of the graphics coordinate transformation.
    var affineTransform: AffineTransform {
        self as AffineTransform
    }
}
#endif
