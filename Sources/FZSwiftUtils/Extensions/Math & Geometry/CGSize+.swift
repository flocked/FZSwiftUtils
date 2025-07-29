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

     The width and height values are scaled based on the screen's backing scale factor.

     - Parameter screen: The screen for the scale.
     */
    func scaledIntegral(for screen: NSScreen) -> CGSize {
        CGSize(width: width.scaledIntegral(for: screen), height: height.scaledIntegral(for: screen))
    }

    /**
     Returns the scaled integral of the size for the specified view.

     The width and height values are scaled based on the view's window backing scale factor.

     - Parameter view: The view for the scale.
     */
    func scaledIntegral(for view: NSView) -> Self {
        guard let window = view.window else { return self }
        return scaledIntegral(for: window)
    }

    /**
     Returns the scaled integral of the size for the specified window.

     The width and height values are scaled based on the window's backing scale factor.

     - Parameter window: The window for the scale.
     */
    func scaledIntegral(for window: NSWindow) -> Self {
        CGSize(width.scaledIntegral(for: window), height.scaledIntegral(for: window))
    }

    /**
     Returns the scaled integral of the size for the specified window.

     The width and height values are scaled based on either the key, main or first visible window, or else the main screen and it's backing scale factor.

     - Parameter application: The application for the scale factor.
     */
    func scaledIntegral(for application: NSApplication) -> Self {
        CGSize(width.scaledIntegral(for: application), height.scaledIntegral(for: application))
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
     The area of the size.

     The area is calculated as the `width` multiplied by the `height`.
     */
    var area: CGFloat {
        width * height
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
    func clamped(min minSize: CGSize) -> CGSize {
        clamped(minWidth: minSize.width, minHeight: minSize.height)
    }

    /**
     Clamps the size to the specified minimum size.

     - Parameter minSize: The minimum size needed.
     */
    mutating func clamp(min minSize: CGSize) {
        self = clamped(min: minSize)
    }

    /**
     Clamps the size to the specified maximum size.

     - Parameter maxSize: The maximum size allowed.
     */
    func clamped(max maxSize: CGSize) -> CGSize {
        clamped(maxWidth: maxSize.width, maxHeight: maxSize.height)
    }

    /**
     Clamps the size to the specified maximum size.

     - Parameter maxSize: The maximum size allowed.
     */
    mutating func clamp(max maxSize: CGSize) {
        self = clamped(max: maxSize)
    }

    /**
     Clamps the size to the specified minimum and maximum size.

     - Parameter sizeRange: The size range to clamp the value to.
     */
    func clamped(to sizeRange: ClosedRange<CGSize>) -> CGSize {
        clamped(min: sizeRange.lowerBound).clamped(max: sizeRange.upperBound)
    }

    /**
     Clamps the size to the specified minimum and maximum size.

     - Parameter sizeRange: The size range to clamp the value to.
     */
    mutating func clamp(to range: ClosedRange<CGSize>) {
        self = clamped(to: range)
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

    /**
     Clamps the size to the specified minimum and maximum values.

     - Parameters:
        - minWidth: The minimum width needed.
        - minHeight: The minimum height needed.
        - maxWidth: The maximum width allowed.
        - maxHeight: The maximum height allowed.
     */
    mutating func clamp(minWidth: CGFloat? = nil, minHeight: CGFloat? = nil, maxWidth: CGFloat? = nil, maxHeight: CGFloat? = nil) {
        self = clamped(minWidth: minWidth, minHeight: minHeight, maxWidth: maxWidth, maxHeight: maxHeight)
    }

    /// The size as `CGPoint`, using the width as x-coordinate and height as y-coordinate.
    var point: CGPoint {
        CGPoint(width, height)
    }

    /// A `CGRect` with the size and origin `zero`.
    var rect: CGRect {
        CGRect(.zero, self)
    }

    /// Returns the size with the specified width.
    func width(_ width: CGFloat) -> CGSize {
        CGSize(width, height)
    }

    /// Returns the size with the specified height.
    func height(_ height: CGFloat) -> CGSize {
        CGSize(width, height)
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

    #if os(macOS) || os(iOS) || os(tvOS)
    /**
     Returns the sizes scaled proportionally to fit within a specified target size, based on the given orientation.

     The scaling maintains the aspect ratio of each size, ensuring that the combined primary dimension (`width` for `horizontal`, `height` for `vertical`) fits within the target size.

     - Parameters:
       - size: The target size within which the sizes should fit.
       - orientation: The orientation that determines how sizes are combined.
     */
    func scaledToFit(_ size: CGSize, orientation: InterfaceOrientation) -> [CGSize] {
        guard !isEmpty else { return [] }
        guard size.width > 0.0, size.height > 0.0 else { return Array(repeating: .zero, count: count) }

        let totalPrimaryLength = reduce(0) { result, current in
            result + (orientation == .vertical ? current.height : current.width)
        }

        let maxSecondaryLength = map { orientation == .vertical ? $0.width : $0.height }.max() ?? 0

        let scaleFactor = Swift.min(
            (orientation == .vertical ? size.height : size.width) / totalPrimaryLength,
            (orientation == .vertical ? size.width : size.height) / maxSecondaryLength
        )

        return map { originalSize in
            CGSize(width: originalSize.width * scaleFactor, height: originalSize.height * scaleFactor)
        }
    }

    /**
     Returns the sizes scaled proportionally to fit within a specified target width, based on the given orientation.

     - Parameters:
       - width: The target width within which the sizes should fit.
       - orientation: The orientation that determines how sizes are combined.
     */
    func scaledToFit(width: CGFloat, orientation: InterfaceOrientation) -> [CGSize] {
        return scaledToFit(CGSize(width: width, height: .greatestFiniteMagnitude), orientation: orientation)
    }

    /**
     Returns the sizes scaled proportionally to fit within a specified target height, based on the given orientation.

     - Parameters:
       - height: The target height within which the sizes should fit.
       - orientation: The orientation that determines how sizes are combined.
     */
    func scaledToFit(height: CGFloat, orientation: InterfaceOrientation) -> [CGSize] {
        return scaledToFit(CGSize(width:.greatestFiniteMagnitude, height: height), orientation: orientation)
    }
    #endif
}

public extension Collection where Element == CGSize {
    /// Aligns the sizes vertically.
    func alignVertical(alignment: CGSize.HorizontalAlignment = .center) -> [CGRect] {
        map{CGRect(.zero, $0)}.alignVertical(alignment: .init(rawValue: alignment.rawValue)!)
    }

    /// Aligns the sizes horizontally.
    func alignHorizontal(alignment: CGSize.VerticalAlignment = .center) -> [CGRect] {
        map{CGRect(.zero, $0)}.alignHorizontal(alignment: .init(rawValue: alignment.rawValue)!)
    }
}

extension CGSize {
    /// The vertical alignment of sizes.
    public enum VerticalAlignment: Int {
        /// bottom.
        case bottom
        /// Center.
        case center
        /// Top.
        case top
    }

    /// The horizontal alignment of sizes.
    public enum HorizontalAlignment: Int {
        /// Left.
        case left
        /// Center.
        case center
        /// Right.
        case right
    }
}
