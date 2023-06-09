//
//  CGSize+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import CoreGraphics
import Foundation

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
        return CGSize(width: width.rounded(rule), height: height.rounded(rule))
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
        return CGSize(width: newWidth, height: newHeight)
    }

    /**
     Scales the size by the specified factor.
     
     - Parameters:
        - factor: The scaling factor.
     
     - Returns: The scaled size with the width and height multiplied by the factor.
     */
    func scaled(byFactor factor: CGFloat) -> CGSize {
        return CGSize(width: width * factor, height: height * factor)
    }

    /**
     Scales the size to fit within the specified rect while maintaining the aspect ratio.
     
     - Parameters:
        - innerRect: The target rect to fit the size within.
     
     - Returns: The scaled size that fits within the innerRect while maintaining the aspect ratio.
     */
    func scaled(toFit innerRect: CGSize) -> CGSize {
        let outerRect = self

        // the width and height ratios of the rects
        let wRatio = outerRect.width / innerRect.width
        let hRatio = outerRect.height / innerRect.height

        // calculate scaling ratio based on the smallest ratio.
        let ratio = (wRatio > hRatio) ? wRatio : hRatio

        // aspect fitted origin and size
        return CGSize(
            width: outerRect.width / ratio,
            height: outerRect.height / ratio
        )
    }

    /**
     Scales the size to fill the specified rect while maintaining the aspect ratio.
     
     - Parameters:
        - innerRect: The target rect to fit the size within.
     
     - Returns: The scaled size that fits within the innerRect while maintaining the aspect ratio.
     */
    func scaled(toFill innerRect: CGSize) -> CGSize {
        let outerRect = self

        // the width and height ratios of the rects
        let wRatio = outerRect.width / innerRect.width
        let hRatio = outerRect.height / innerRect.height

        // calculate scaling ratio based on the smallest ratio.
        let ratio = (wRatio < hRatio) ? wRatio : hRatio

        // aspect fitted origin and size
        return CGSize(
            width: outerRect.width / ratio,
            height: outerRect.height / ratio
        )
    }
}

public extension CGSize {
    static func + (l: CGSize, r: CGSize) -> CGSize {
        return CGSize(width: l.width + r.width, height: l.height + r.height)
    }

    static func + (l: CGSize, r: CGFloat) -> CGSize {
        return CGSize(width: l.width + r, height: l.height + r)
    }

    static func + (l: CGSize, r: Double) -> CGSize {
        return CGSize(width: l.width + r, height: l.height + r)
    }

    static func - (l: CGSize, r: CGSize) -> CGSize {
        return CGSize(width: l.width - r.width, height: l.height - r.height)
    }

    static func - (l: CGSize, r: CGFloat) -> CGSize {
        return CGSize(width: l.width - r, height: l.height - r)
    }

    static func - (l: CGSize, r: Double) -> CGSize {
        return CGSize(width: l.width - r, height: l.height - r)
    }

    static func * (l: CGSize, r: CGFloat) -> CGSize {
        return CGSize(width: l.width * r, height: l.height * r)
    }

    static func * (l: CGSize, r: Double) -> CGSize {
        return CGSize(width: l.width * r, height: l.height * r)
    }

    static func / (l: CGSize, r: CGFloat) -> CGSize {
        return CGSize(width: l.width / r, height: l.height / r)
    }

    static func / (l: CGSize, r: Double) -> CGSize {
        return CGSize(width: l.width / r, height: l.height / r)
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
