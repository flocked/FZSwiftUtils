//
//  CGSize+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import CoreGraphics
import Foundation
#if os(macOS)
    import AppKit
#endif

public extension CGSize {
    /// Creates a size with the specified width and height.
    init(_ width: CGFloat, _ height: CGFloat) {
        self.init(width: width, height: height)
    }

    /// Creates a size with the specified width and height.
    init(_ widthHeight: CGFloat) {
        self.init(width: widthHeight, height: widthHeight)
    }

    /**
     Returns the scaled integral of the size.
     
     The width and height values are scaled based on the current device's screen scale.
     */
    var scaledIntegral: CGSize {
        CGSize(width: width.scaledIntegral, height: height.scaledIntegral)
    }
    
    #if os(macOS)
    /**
     Returns the scaled integral of the size for the specified screen.
     
     The width and height values are scaled based on the screen scale.

     - Parameter screen: The screen for the scale.
     */
    func scaledIntegral(for screen: NSScreen) -> CGSize {
        CGSize(width: width.scaledIntegral(for: screen), height: height.scaledIntegral(for: screen))
    }
    #endif

    /**
     Returns the aspect ratio of the size.
     
     The aspect ratio is calculated as the `width` divided by the `height`.
     */
    var aspectRatio: CGFloat {
        if height == 0 { return 1 }
        return width / height
    }

    /**
     Rounds the width and height values using the specified rounding rule.

     - Parameter rule: The rounding rule to be applied. The default value is `.toNearestOrAwayFromZero`.

     - Returns: The size with rounded width and height values.
     */
    func rounded(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> CGSize {
        CGSize(width: width.rounded(rule), height: height.rounded(rule))
    }

    /**
     Scales the size to the specified width while maintaining the aspect ratio.

     - Parameter newWidth: The target width for scaling.
     */
    func scaled(toWidth newWidth: CGFloat) -> CGSize {
        let scale = newWidth / width
        let newHeight = height * scale
        return CGSize(width: newWidth, height: newHeight)
    }

    /**
     Scales the size to the specified height while maintaining the aspect ratio.

     - Parameter newHeight: The target height for scaling.
     */
    func scaled(toHeight newHeight: CGFloat) -> CGSize {
        let scale = newHeight / height
        let newWidth = width * scale
        return CGSize(width: newWidth, height: newHeight)
    }
    
    /**
     Scales the size by the specified factor.

     - Parameter factor: The scaling factor.

     - Returns: The scaled size with the width and height multiplied by the factor.
     */
    func scaled(byFactor factor: CGFloat) -> CGSize {
        CGSize(width: width * factor, height: height * factor)
    }

    /**
     Scales the size to fit within the specified size while maintaining the aspect ratio.

     - Parameter size: The target size to fit the size within.
     */
    func scaled(toFit size: CGSize) -> CGSize {
        var size = size
        if size.width == -1 || size.width == .greatestFiniteMagnitude || size.width == 0 {
            size.width = width
        }
        if size.height == -1 || size.height == .greatestFiniteMagnitude || size.height == 0 {
            size.height = height
        }
        let ratio = max(width / size.width, height / size.height)
        return CGSize(width: width / ratio, height: height / ratio)
    }

    /**
     Scales the size to fill the specified size while maintaining the aspect ratio.

     - Parameter size: The target size to fill the size within.
     */
    func scaled(toFill size: CGSize) -> CGSize {
        var newSize = self
        if size.width > size.height {
            newSize = newSize.scaled(toWidth: size.width)
            if  newSize.height < size.height {
                newSize = newSize.scaled(toHeight: size.height)
            }
        } else {
            newSize = newSize.scaled(toHeight: size.height)
            if newSize.width < size.width {
                newSize = newSize.scaled(toWidth: size.width)
            }
        }
      return newSize
    }
    
    /**
     Clamps the size to the specified minimum size.
     
     - Parameter minSize: The minimum size needed.
     */
    func clamped(minSize: CGSize) -> CGSize {
        clamped(minWidth: minSize.width, minHeight: minSize.height)
    }
    
    /**
     Clamps the size to the specified maximum size.
     
     - Parameter maxSize: The maximum size allowed.
     */
    func clamped(maxSize: CGSize) -> CGSize {
        clamped(maxWidth: maxSize.width, maxHeight: maxSize.height)
    }
    
    /**
     Clamps the size to the specified minimum and maximum size.
     
     - Parameters:
        - minSize: The minimum size needed.
        - maxSize: The maximum size allowed.
     */
    func clamped(minSize: CGSize, maxSize: CGSize) -> CGSize {
        clamped(minSize: minSize).clamped(maxSize: maxSize)
    }
        
    /**
     Clamps the size to the specified minimum and maximum values.
     
     - Parameters:
        - minWidth: The minimum width needed.
        - minHeight: The minimum height needed.
        - maxWidth: The maximum width allowed.
        - maxHeight: The maximum height allowed.
     */
    func clamped(minWidth: CGFloat? = nil, minHeight: CGFloat? = nil, maxWidth: CGFloat? = nil, maxHeight: CGFloat? = nil) -> CGSize {
        var size = self
        if let minWidth = minWidth, minWidth != 3.4028234663852886e+38 {
            size.width = size.width.clamped(min: minWidth)
        }
        if let minHeight = minHeight, minHeight != 3.4028234663852886e+38 {
            size.height = size.height.clamped(min: minHeight)
        }
        if let maxWidth = maxWidth, maxWidth != 3.4028234663852886e+38 {
            size.width = size.width.clamped(min: maxWidth)
        }
        if let maxHeight = maxHeight, maxHeight != 3.4028234663852886e+38 {
            size.height = size.height.clamped(min: maxHeight)
        }
        return size
    }

    /// The size as `CGPoint`, using the width as x-coordinate and height as y-coordinate.
    var point: CGPoint {
        CGPoint(width, height)
    }
    
    /// Returns the size with the specified width.
    func width(_ width: CGFloat) -> CGSize {
        CGSize(width, height)
    }
    
    /// Returns the size with the specified height.
    func height(_ height: CGFloat) -> CGSize {
        CGSize(width, height)
    }
    
    /// The area of the size.
    var area: CGFloat {
        width * height
    }
}

public extension CGSize {
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    static func + (lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width + rhs, height: lhs.height + rhs)
    }

    static func + (lhs: CGSize, rhs: Double) -> CGSize {
        CGSize(width: lhs.width + rhs, height: lhs.height + rhs)
    }

    static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }

    static func - (lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width - rhs, height: lhs.height - rhs)
    }

    static func - (lhs: CGSize, rhs: Double) -> CGSize {
        CGSize(width: lhs.width - rhs, height: lhs.height - rhs)
    }

    static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }

    static func * (lhs: CGSize, rhs: Double) -> CGSize {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }

    static func / (lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }

    static func / (lhs: CGSize, rhs: Double) -> CGSize {
        CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }

    static func += (lhs: inout CGSize, rhs: CGSize) {
        lhs = lhs + rhs
    }

    static func += (lhs: inout CGSize, rhs: CGFloat) {
        lhs = lhs + rhs
    }

    static func += (lhs: inout CGSize, rhs: Double) {
        lhs = lhs + rhs
    }

    static func -= (lhs: inout CGSize, rhs: CGSize) {
        lhs = lhs - rhs
    }

    static func -= (lhs: inout CGSize, rhs: CGFloat) {
        lhs = lhs - rhs
    }

    static func -= (lhs: inout CGSize, rhs: Double) {
        lhs = lhs - rhs
    }

    static func *= (lhs: inout CGSize, rhs: CGFloat) {
        lhs = lhs * rhs
    }

    static func *= (lhs: inout CGSize, rhs: Double) {
        lhs = lhs * rhs
    }
    
    static func /= (lhs: inout CGSize, rhs: CGFloat) {
        lhs = lhs / rhs
    }

    static func /= (lhs: inout CGSize, rhs: Double) {
        lhs = lhs / rhs
    }
}

extension CGSize: Comparable {
    public static func < (lhs: CGSize, rhs: CGSize) -> Bool {
        lhs.area < rhs.area
    }
}

extension CGSize: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
    }
}

public extension Collection where Element == CGSize {
    /// The size to fit all sizes of the collection.
    func totalSize() -> CGSize {
        var totalSize: CGSize = .zero
        for size in self {
            totalSize.width = Swift.max(totalSize.width, size.width)
            totalSize.height = Swift.max(totalSize.height, size.height)
        }
        return totalSize
    }
}
