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
     Returns the scaled integral size of the size.
     
     The width and height values are scaled based on the current device's screen scale.

     - Returns: The scaled integral size of the size.
     */
    var scaledIntegral: CGSize {
        CGSize(width: width.scaledIntegral, height: height.scaledIntegral)
    }
    
    #if os(macOS)
    /**
     Returns the scaled integral size of the size for the specified screen.
     
     The width and height values are scaled based on the screen scale.

     - Parameter screen: The screen for the scale.
     - Returns: The scaled integral size of the size.
     */
    func scaledIntegral(for screen: NSScreen) -> CGSize {
        CGSize(width: width.scaledIntegral(for: screen), height: height.scaledIntegral(for: screen))
    }
    #endif

    /**
     Returns the aspect ratio of the size.
     The aspect ratio is calculated as the width divided by the height.

     - Returns: The aspect ratio of the size.
     */
    var aspectRatio: CGFloat {
        if height == 0 { return 1 }
        return width / height
    }

    /**
     Rounds the width and height values of the size using the specified rounding rule.

     - Parameters:
        - rule: The rounding rule to be applied. The default value is `.toNearestOrAwayFromZero`.

     - Returns: The size with rounded width and height values.
     */
    func rounded(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> CGSize {
        CGSize(width: width.rounded(rule), height: height.rounded(rule))
    }

    /**
     Scales the size to the specified width while maintaining the aspect ratio.

     - Parameters:
        - newWidth: The target width for scaling.

     - Returns: The scaled size with the new width and height calculated based on the aspect ratio.
     */
    func scaled(toWidth newWidth: CGFloat) -> CGSize {
        let scale = newWidth / width
        let newHeight = height * scale
        return CGSize(width: newWidth, height: newHeight)
    }

    /**
     Scales the size to the specified height while maintaining the aspect ratio.

     - Parameters:
        - newHeight: The target height for scaling.

     - Returns: The scaled size with the new width and height calculated based on the aspect ratio.
     */
    func scaled(toHeight newHeight: CGFloat) -> CGSize {
        let scale = newHeight / height
        let newWidth = width * scale
       // self.clamped
        return CGSize(width: newWidth, height: newHeight)
    }
    
    /**
     Scales the size by the specified factor.

     - Parameters:
        - factor: The scaling factor.

     - Returns: The scaled size with the width and height multiplied by the factor.
     */
    func scaled(byFactor factor: CGFloat) -> CGSize {
        CGSize(width: width * factor, height: height * factor)
    }

    /**
     Scales the size to fit within the specified size while maintaining the aspect ratio.

     - Parameters:
        - size: The target size to fit the size within.

     - Returns: The scaled size that fits within the size while maintaining the aspect ratio.
     */
    func scaled(toFit size: CGSize) -> CGSize {
        if (size.width == -1 || size.width == .greatestFiniteMagnitude), (size.height == -1 || size.height == .greatestFiniteMagnitude) {
            return self
        } else if size.width == -1 || size.width == .greatestFiniteMagnitude {
            return scaled(toHeight: size.height)
        } else if size.height == -1 || size.height == .greatestFiniteMagnitude {
            return scaled(toWidth: size.width)
        }
        let wRatio = width / size.width
        let hRatio = height / size.height
        let ratio = (wRatio > hRatio) ? wRatio : hRatio
        return CGSize(width: width / ratio, height: height / ratio)
    }

    /**
     Scales the size to fill the specified size while maintaining the aspect ratio.

     - Parameters:
        - size: The target size to fill the size within.

     - Returns: The scaled size that fills the specified size while maintaining the aspect ratio.
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
     - Returns: The clamped size.
     */
    func clamped(minSize: CGSize) -> CGSize {
        var size = self
        size.width = size.width.clamped(min: minSize.width)
        size.height = size.height.clamped(min: minSize.height)
        return size
    }
    
    /**
     Clamps the size to the specified maximum size.
     
     - Parameter maxSize: The maximum size allowed.
     - Returns: The clamped size.
     */
    func clamped(maxSize: CGSize) -> CGSize {
        var size = self
        size.width = size.width.clamped(to: 0...maxSize.width)
        size.height = size.height.clamped(to: 0...maxSize.height)
        return size
    }
        
    /**
     Clamps the size to the specified minimum and maximum values.
     
     - Parameters:
        - minWidth: The minimum width needed.
        - minHeight: The minimum height needed.
        - maxWidth: The maximum width allowed.
        - maxHeight: The maximum height allowed.
     - Returns: The clamped size.
     */
    func clamped(minWidth: CGFloat? = nil, minHeight: CGFloat? = nil, maxWidth: CGFloat? = nil, maxHeight: CGFloat? = nil) -> CGSize {
        var size = self
        size.width = size.width.clamped(min: minWidth ?? width)
        size.height = size.height.clamped(min: minHeight ?? height)
        if let maxWidth = maxWidth, width > maxWidth {
            size.width = width.clamped(to: 0...maxWidth)
        }
        if let maxHeight = maxHeight, height > maxHeight {
            size.height = height.clamped(to: 0...maxHeight)
        }
        return size
    }

    /// The size as `CGPoint`, using the width as x-coordinate and height as y-coordinate.
    var point: CGPoint {
        CGPoint(width, height)
    }
    
    /// Returns the size with the specified width.
    func width(_ value: CGFloat) -> CGSize {
        CGSize(value, height)
    }
    
    /// Returns the size with the specified height.
    func height(_ value: CGFloat) -> CGSize {
        CGSize(width, value)
    }
}

public extension CGSize {
    static func + (l: CGSize, r: CGSize) -> CGSize {
        CGSize(width: l.width + r.width, height: l.height + r.height)
    }

    static func + (l: CGSize, r: CGFloat) -> CGSize {
        CGSize(width: l.width + r, height: l.height + r)
    }

    static func + (l: CGSize, r: Double) -> CGSize {
        CGSize(width: l.width + r, height: l.height + r)
    }

    static func - (l: CGSize, r: CGSize) -> CGSize {
        CGSize(width: l.width - r.width, height: l.height - r.height)
    }

    static func - (l: CGSize, r: CGFloat) -> CGSize {
        CGSize(width: l.width - r, height: l.height - r)
    }

    static func - (l: CGSize, r: Double) -> CGSize {
        CGSize(width: l.width - r, height: l.height - r)
    }

    static func * (l: CGSize, r: CGFloat) -> CGSize {
        CGSize(width: l.width * r, height: l.height * r)
    }

    static func * (l: CGSize, r: Double) -> CGSize {
        CGSize(width: l.width * r, height: l.height * r)
    }

    static func / (l: CGSize, r: CGFloat) -> CGSize {
        CGSize(width: l.width / r, height: l.height / r)
    }

    static func / (l: CGSize, r: Double) -> CGSize {
        CGSize(width: l.width / r, height: l.height / r)
    }

    static func += (l: inout CGSize, r: CGSize) {
        l = CGSize(width: l.width + r.width, height: l.height + r.width)
    }

    static func += (l: inout CGSize, r: CGFloat) {
        l = CGSize(width: l.width + r, height: l.height + r)
    }

    static func += (l: inout CGSize, r: Double) {
        l = CGSize(width: l.width + r, height: l.height + r)
    }

    static func -= (l: inout CGSize, r: CGSize) {
        l = CGSize(width: l.width - r.width, height: l.height - r.width)
    }

    static func -= (l: inout CGSize, r: CGFloat) {
        l = CGSize(width: l.width - r, height: l.height - r)
    }

    static func -= (l: inout CGSize, r: Double) {
        l = CGSize(width: l.width - r, height: l.height - r)
    }

    static func *= (l: inout CGSize, r: CGFloat) {
        l = CGSize(width: l.width * r, height: l.height * r)
    }

    static func *= (l: inout CGSize, r: Double) {
        l = CGSize(width: l.width * r, height: l.height * r)
    }
}

extension CGSize: Comparable {
    public static func > (lhs: CGSize, rhs: CGSize) -> Bool {
        lhs.width * lhs.height > rhs.width * rhs.height
    }

    public static func >= (lhs: CGSize, rhs: CGSize) -> Bool {
        lhs.width * lhs.height >= rhs.width * rhs.height
    }

    public static func < (lhs: CGSize, rhs: CGSize) -> Bool {
        lhs.width * lhs.height < rhs.width * rhs.height
    }

    public static func <= (lhs: CGSize, rhs: CGSize) -> Bool {
        lhs.width * lhs.height <= rhs.width * rhs.height
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
