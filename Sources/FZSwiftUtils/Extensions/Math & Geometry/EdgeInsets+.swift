//
//  NSUIEdgeInset+.swift
//
//
//  Created by Florian Zand on 07.06.22.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI

#if os(macOS)
public extension CGRect {
    func inset(by edgeInsets: EdgeInsets) -> CGRect {
        inset(by: edgeInsets.directional)
    }
}
#endif

extension NSUIEdgeInsets: Swift.Hashable {
    #if os(macOS)
    /// An edge insets struct whose top, left, bottom, and right fields are all set to 0.
    public static let zero = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    #endif

    /// Creates an edge insets structure with the specified value for top, bottom, left and right.
    public init(_ value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }

    /// Creates an edge insets structure with the specified width (left + right) and height (top + bottom) values.
    public init(width: CGFloat, height: CGFloat = 0) {
        self.init()
        self.width = width
        self.height = height
    }

    /// Creates an edge insets structure with the specified height (top + bottom) value.
    public init(height: CGFloat) {
        self.init()
        self.height = height
    }
    
    /// Creates an edge insets with the specified `left` value.
    public static func left(_ left: CGFloat) -> Self {
        Self(top: 0, left: left, bottom: 0, right: 0)
    }
    
    /// Creates an edge insets with the specified `right` value.
    public static func right(_ right: CGFloat) -> Self {
        Self(top: 0, left: 0, bottom: 0, right: right)
    }
    
    /// Creates an edge insets with the specified `top` value.
    public static func top(_ top: CGFloat) -> Self {
        Self(top: top, left: 0, bottom: 0, right: 0)
    }
    
    /// Creates an edge insets with the specified `bottom` value.
    public static func bottom(_ bottom: CGFloat) -> Self {
        Self(top: 0, left: 0, bottom: bottom, right: 0)
    }

    /// The width (left + right) of the insets.
    public var width: CGFloat {
        get { left + right }
        set {
            let value = newValue / 2.0
            left = value
            right = value
        }
    }

    /// The height (top + bottom) of the insets.
    public var height: CGFloat {
        get { top + bottom }
        set {
            let value = newValue / 2.0
            top = value
            bottom = value
        }
    }
    
    /// Clamps the insets to the specified minimum value.
    public func clamped(min: Self) -> Self {
        Self(top: top.clamped(min: min.top), left: left.clamped(min: min.left), bottom: bottom.clamped(min: min.bottom), right: right.clamped(min: min.right))
    }

    /// Clamps the insets to the specified maximum value.
    public func clamped(max: Self) -> Self {
        Self(top: top.clamped(max: max.top), left: left.clamped(max: max.left), bottom: bottom.clamped(max: max.bottom), right: right.clamped(max: max.right))
    }

    /// Clamps the insets to the specified minimum value.
    public mutating func clamp(min: Self) {
        self = clamped(min: min)
    }

    /// Clamps the insets to the specified maximum value.
    public mutating func clamp(max: Self) {
        self = clamped(max: max)
    }

    /// The insets as `NSDirectionalEdgeInsets`.
    public var directional: NSDirectionalEdgeInsets {
        .init(top: top, leading: left, bottom: bottom, trailing: right)
    }

    /// The insets as `EdgeInsets`.
    public var edgeInsets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
    
    public static func == (lhs: NSUIEdgeInsets, rhs: NSUIEdgeInsets) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(top)
        hasher.combine(bottom)
        hasher.combine(left)
        hasher.combine(right)
    }
    
    public static func +(lhs: Self, rhs: Self) -> Self {
        .init(top: lhs.top + rhs.top, left: lhs.left + rhs.left, bottom: lhs.bottom + rhs.bottom, right: lhs.right + rhs.right)
    }
    
    public static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
    
    public static func -(lhs: Self, rhs: Self) -> Self {
        .init(top: lhs.top - rhs.top, left: lhs.left - rhs.left, bottom: lhs.bottom - rhs.bottom, right: lhs.right - rhs.right)
    }
    
    public static func -= (lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }
    
    public static func +(lhs: Self, rhs: CGFloat) -> Self {
        .init(top: lhs.top + rhs, left: lhs.left + rhs, bottom: lhs.bottom + rhs, right: lhs.right + rhs)
    }
    
    public static func += (lhs: inout Self, rhs: CGFloat) {
        lhs = lhs + rhs
    }
    
    public static func -(lhs: Self, rhs: CGFloat) -> Self {
        .init(top: lhs.top - rhs, left: lhs.left - rhs, bottom: lhs.bottom - rhs, right: lhs.right - rhs)
    }
    
    public static func -= (lhs: inout Self, rhs: CGFloat) {
        lhs = lhs - rhs
    }
}

#if os(macOS)
extension NSEdgeInsets: Swift.Equatable { }
#endif

#if os(macOS)
extension NSUIEdgeInsets: Swift.Encodable, Swift.Decodable {
    public enum CodingKeys: String, CodingKey {
        case top
        case bottom
        case left
        case right
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(top, forKey: .top)
        try container.encode(bottom, forKey: .bottom)
        try container.encode(left, forKey: .left)
        try container.encode(right, forKey: .right)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self = try .init(top: container.decode(.top), left: container.decode(.left), bottom: container.decode(.bottom), right: container.decode(.right))
    }
}
#endif

extension NSDirectionalEdgeInsets: Swift.Hashable {
    #if os(macOS)
    /// A directional edge insets structure whose top, leading, bottom, and trailing fields all have a value of ´0´.
    public static let zero = NSDirectionalEdgeInsets(0)
    #endif

    /// Creates an edge insets structure with the specified value for top, bottom, leading and trailing.
    public init(_ value: CGFloat) {
        self.init(top: value, leading: value, bottom: value, trailing: value)
    }

    /// Creates an edge insets structure with the specified width (leading + trailing) and height (top + bottom) values.
    public init(width: CGFloat, height: CGFloat = 0) {
        self.init()
        self.width = width
        self.height = height
    }

    /// Creates an edge insets structure with the specified height (top + bottom) value.
    public init(height: CGFloat) {
        self.init()
        self.height = height
    }
    
    /// Creates an edge insets with the specified `leading` value.
    public static func leading(_ leading: CGFloat) -> Self {
        Self(top: 0, leading: leading, bottom: 0, trailing: 0)
    }
    
    /// Creates an edge insets with the specified `trailing` value.
    public static func trailing(_ trailing: CGFloat) -> Self {
        Self(top: 0, leading: 0, bottom: 0, trailing: trailing)
    }
    
    /// Creates an edge insets with the specified `top` value.
    public static func top(_ top: CGFloat) -> Self {
        Self(top: top, leading: 0, bottom: 0, trailing: 0)
    }
    
    /// Creates an edge insets with the specified `bottom` value.
    public static func bottom(_ bottom: CGFloat) -> Self {
        Self(top: 0, leading: 0, bottom: bottom, trailing: 0)
    }

    /// The width (leading + trailing) of the insets.
    public var width: CGFloat {
        get { leading + trailing }
        set {
            let value = newValue / 2.0
            leading = value
            trailing = value
        }
    }

    /// The height (top + bottom) of the insets.
    public var height: CGFloat {
        get { top + bottom }
        set {
            let value = newValue / 2.0
            top = value
            bottom = value
        }
    }

    /// The insets as `EdgeInsets`.
    public var edgeInsets: EdgeInsets {
        EdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing)
    }

    #if os(macOS)
    /// The insets as `NSEdgeInsets`.
    public var nsEdgeInsets: NSEdgeInsets {
        .init(top: self.top, left: self.leading, bottom: self.bottom, right: self.trailing)
    }

    #elseif canImport(UIKit)
    /// The insets as `UIEdgeInsets`.
    public var uiEdgeInsets: UIEdgeInsets {
        .init(top: top, left: leading, bottom: bottom, right: trailing)
    }
    #endif

    /// Clamps the insets to the specified minimum value.
    public func clamped(min: Self) -> Self {
        NSDirectionalEdgeInsets(top: top.clamped(min: min.top), leading: leading.clamped(min: min.leading), bottom: bottom.clamped(min: min.bottom), trailing: trailing.clamped(min: min.trailing))
    }
    
    /// Clamps the insets to the specified maximum value.
    public func clamped(max: Self) -> Self {
        NSDirectionalEdgeInsets(top: top.clamped(max: max.top), leading: leading.clamped(max: max.leading), bottom: bottom.clamped(max: max.bottom), trailing: trailing.clamped(max: max.trailing))
    }

    /// Clamps the insets to the specified minimum value.
    public mutating func clamp(min: Self) {
        self = clamped(min: min)
    }

    /// Clamps the insets to the specified maximum value.
    public mutating func clamp(max: Self) {
        self = clamped(max: max)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.top == rhs.top && lhs.bottom == rhs.bottom && lhs.leading == rhs.leading && lhs.trailing == rhs.trailing
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(top)
        hasher.combine(bottom)
        hasher.combine(trailing)
        hasher.combine(leading)
    }
    
    public static func +(lhs: Self, rhs: Self) -> Self {
        .init(top: lhs.top + rhs.top, leading: lhs.leading + rhs.leading, bottom: lhs.bottom + rhs.bottom, trailing: lhs.trailing + rhs.trailing)
    }
    
    public static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
    
    public static func -(lhs: Self, rhs: Self) -> Self {
        .init(top: lhs.top - rhs.top, leading: lhs.leading - rhs.leading, bottom: lhs.bottom - rhs.bottom, trailing: lhs.trailing - rhs.trailing)
    }
    
    public static func -= (lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }
    
    public static func +(lhs: Self, rhs: CGFloat) -> Self {
        .init(top: lhs.top + rhs, leading: lhs.leading + rhs, bottom: lhs.bottom + rhs, trailing: lhs.trailing + rhs)
    }
    
    public static func += (lhs: inout Self, rhs: CGFloat) {
        lhs = lhs + rhs
    }
    
    public static func -(lhs: Self, rhs: CGFloat) -> Self {
        .init(top: lhs.top - rhs, leading: lhs.leading - rhs, bottom: lhs.bottom - rhs, trailing: lhs.trailing - rhs)
    }
    
    public static func -= (lhs: inout Self, rhs: CGFloat) {
        lhs = lhs - rhs
    }
}

#if os(macOS)
extension NSDirectionalEdgeInsets: Swift.Equatable { }
#endif

#if os(macOS)
extension NSDirectionalEdgeInsets: Swift.Encodable, Swift.Decodable {
    public enum CodingKeys: String, CodingKey {
        case top
        case bottom
        case leading
        case trailing
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(top, forKey: .top)
        try container.encode(bottom, forKey: .bottom)
        try container.encode(leading, forKey: .leading)
        try container.encode(trailing, forKey: .trailing)
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self = try .init(top: values.decode(.top), leading: values.decode(.leading), bottom: values.decode(.bottom), trailing: values.decode(.trailing))
    }
}
#endif

extension EdgeInsets: Swift.Hashable, Swift.Encodable, Swift.Decodable {
    /// An edge insets struct whose top, leading, bottom, and trailing fields are all set to 0.
    public static let zero = EdgeInsets(0)

    /// Creates an edge insets structure whose specified edges have the value.
    public init(_ edges: Edge.Set, _ value: CGFloat) {
        CGRect().fill()
        self.init(top: edges.contains(.top) ? value : 0, leading: edges.contains(.leading) ? value : 0, bottom: edges.contains(.bottom) ? value : 0, trailing: edges.contains(.trailing) ? value : 0)
    }

    /// Creates an edge insets structure with the specified value for top, bottom, leading and right.
    public init(_ value: CGFloat) {
        self.init(top: value, leading: value, bottom: value, trailing: value)
    }

    /// Creates an edge insets structure with the specified width (leading + trailing) and height (top + bottom) values.
    public init(width: CGFloat, height: CGFloat = 0) {
        self.init()
        self.width = width
        self.height = height
    }

    /// Creates an edge insets structure with the specified height (top + bottom) value.
    public init(height: CGFloat) {
        self.init()
        self.height = height
    }
    
    /// Creates an edge insets with the specified `leading` value.
    public static func leading(_ leading: CGFloat) -> Self {
        Self(top: 0, leading: leading, bottom: 0, trailing: 0)
    }
    
    /// Creates an edge insets with the specified `trailing` value.
    public static func trailing(_ trailing: CGFloat) -> Self {
        Self(top: 0, leading: 0, bottom: 0, trailing: trailing)
    }
    
    /// Creates an edge insets with the specified `top` value.
    public static func top(_ top: CGFloat) -> Self {
        Self(top: top, leading: 0, bottom: 0, trailing: 0)
    }
    
    /// Creates an edge insets with the specified `bottom` value.
    public static func bottom(_ bottom: CGFloat) -> Self {
        Self(top: 0, leading: 0, bottom: bottom, trailing: 0)
    }

    /// The width (leading + trailing) of the insets.
    public var width: CGFloat {
        get { leading + trailing }
        set {
            let value = newValue / 2.0
            leading = value
            trailing = value
        }
    }

    /// The height (top + bottom) of the insets.
    public var height: CGFloat {
        get { top + bottom }
        set {
            let value = newValue / 2.0
            top = value
            bottom = value
        }
    }

    /// The insets as `NSDirectionalEdgeInsets`.
    public var directional: NSDirectionalEdgeInsets {
        .init(top: top, leading: leading, bottom: bottom, trailing: trailing)
    }

    #if os(macOS)
    /// The insets as `NSEdgeInsets`.
    public var nsEdgeInsets: NSEdgeInsets {
        .init(top: self.top, left: self.leading, bottom: self.bottom, right: self.trailing)
    }
    #elseif canImport(UIKit)
    /// The insets as `UIEdgeInsets`.
    public var uiEdgeInsets: UIEdgeInsets {
        .init(top: top, left: leading, bottom: bottom, right: trailing)
    }
    #endif

    /// Clamps the insets to the specified minimum value.
    public func clamped(min: Self) -> Self {
        EdgeInsets(top: top.clamped(min: min.top), leading: leading.clamped(min: min.leading), bottom: bottom.clamped(min: min.bottom), trailing: trailing.clamped(min: min.trailing))
    }

    /// Clamps the insets to the specified maximum value.
    public func clamped(max: Self) -> Self {
        EdgeInsets(top: top.clamped(max: max.top), leading: leading.clamped(max: max.leading), bottom: bottom.clamped(max: max.bottom), trailing: trailing.clamped(max: max.trailing))
    }

    /// Clamps the insets to the specified minimum value.
    public mutating func clamp(min: Self) {
        self = clamped(min: min)
    }

    /// Clamps the insets to the specified maximum value.
    public mutating func clamp(max: Self) {
        self = clamped(max: max)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(top)
        hasher.combine(bottom)
        hasher.combine(leading)
        hasher.combine(trailing)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(top, forKey: .top)
        try container.encode(bottom, forKey: .bottom)
        try container.encode(leading, forKey: .leading)
        try container.encode(trailing, forKey: .trailing)
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self = try .init(top: values.decode(.top), leading: values.decode(.leading), bottom: values.decode(.bottom), trailing: values.decode(.trailing))
    }
    
    public enum CodingKeys: String, CodingKey {
        case top
        case bottom
        case leading
        case trailing
    }
    
    public static func +(lhs: Self, rhs: Self) -> Self {
        .init(top: lhs.top + rhs.top, leading: lhs.leading + rhs.leading, bottom: lhs.bottom + rhs.bottom, trailing: lhs.trailing + rhs.trailing)
    }
    
    public static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
    
    public static func -(lhs: Self, rhs: Self) -> Self {
        .init(top: lhs.top - rhs.top, leading: lhs.leading - rhs.leading, bottom: lhs.bottom - rhs.bottom, trailing: lhs.trailing - rhs.trailing)
    }
    
    public static func -= (lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }
    
    public static func +(lhs: Self, rhs: CGFloat) -> Self {
        .init(top: lhs.top + rhs, leading: lhs.leading + rhs, bottom: lhs.bottom + rhs, trailing: lhs.trailing + rhs)
    }
    
    public static func += (lhs: inout Self, rhs: CGFloat) {
        lhs = lhs + rhs
    }
    
    public static func -(lhs: Self, rhs: CGFloat) -> Self {
        .init(top: lhs.top - rhs, leading: lhs.leading - rhs, bottom: lhs.bottom - rhs, trailing: lhs.trailing - rhs)
    }
    
    public static func -= (lhs: inout Self, rhs: CGFloat) {
        lhs = lhs - rhs
    }
}

extension Edge.Set {
    /// Leading and trailing edge.
    public static let width: Self = [.leading, .trailing]

    /// Top and bottom edge.
    public static let height: Self = [.top, .bottom]
}
