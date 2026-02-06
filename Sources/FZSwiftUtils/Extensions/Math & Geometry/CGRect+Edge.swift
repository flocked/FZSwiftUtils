//
//  CGRect+Edge.swift
//  
//
//  Created by Florian Zand on 14.11.25.
//

import Foundation

// MARK: - Edge

extension CGRect {
    /// An enumeration to indicate one edge of a rectangle.
    public enum Edge: UInt8, Hashable, Codable, CaseIterable, CustomStringConvertible {
        /// Left edge.
        case left
        /// Right edge.
        case right
        /// Bottom edge.
        case bottom
        /// Top edge.
        case top
        
        /// Edge at `minX`.
        static let minX = Self.left
        /// Edge at `maxX`.
        static let maxX = Self.right
        #if os(macOS)
        /// Edge at `minY`.
        static let minY = Self.bottom
        /// Edge at `maxY`.
        static let maxY = Self.top
        #else
        /// Edge at `minY`.
        static let minY = Self.top
        /// Edge at `maxY`.
        static let maxY = Self.bottom
        #endif
        
        public var description: String {
            switch self {
            case .left: return "left"
            case .right: return "right"
            case .bottom: return "bottom"
            case .top: return "top"
            }
        }

        /// An set of rectangle edges.
        public struct Set: OptionSet, Hashable, Codable, CustomStringConvertible {
            /// Left edge.
            public static let left = minX
            /// Right edge.
            public static let right = maxX
            #if os(macOS)
            /// Bottom edge.
            public static let bottom = minY
            /// Top edge.
            public static let top = maxY
            #else
            /// Bottom edge.
            public static let bottom = maxY
            /// Top edge.
            public static let top = minY
            #endif
            
            /// Edge at `minX`.
            static let minX = Self(rawValue: 1 << 0)
            /// Edge at `maxX`.
            static let maxX = Self(rawValue: 1 << 1)
            /// Edge at `minY`.
            static let minY = Self(rawValue: 1 << 2)
            /// Edge at `maxY`.
            static let maxY = Self(rawValue: 1 << 3)
            
            public var description: String {
                var strings: [String] = []
                if contains(.left) { strings += "left" }
                if contains(.right) { strings += "right" }
                if contains(.bottom) { strings += "bottom" }
                if contains(.top) { strings += "top" }
                return "[" + strings.sorted().joined(separator: ", ") + "]"
            }
            
            /// All edges.
            public static let all: Self = [.left, .right, .bottom, .top]
            /// Left and right edge.
            public static let horizontal: Self = [.left, .right]
            /// Bottom and top edge.
            public static let vertical: Self = [.bottom, .top]
            
            public let rawValue: UInt8
            
            public init(rawValue: UInt8) {
                self.rawValue = rawValue
            }
            
            /// Creates set of edges containing only the specified edge.
            public init(_ edge: Edge) {
                switch edge {
                case .left: self = .left
                case .right: self = .right
                case .bottom: self = .bottom
                case .top: self = .top
                }
            }
        }
    }
    
    @_disfavoredOverload
    public subscript(edge: Edge) -> CGPoint {
        get {
            switch edge {
            case .top: return topCenter
            case .left: return centerLeft
            case .bottom: return bottomCenter
            case .right: return centerRight
            }
        }
        set {
            switch edge {
            case .top: topCenter = newValue
            case .left: centerLeft = newValue
            case .bottom: bottomCenter = newValue
            case .right: centerRight = newValue
            }
        }
    }
}

// MARK: - Corner

extension CGRect {
    /// An enumeration to indicate one corner of a rectangle.
    public enum Corner: UInt8, Hashable, Codable, CaseIterable, CustomStringConvertible {
        /// Bottom-left corner.
        case bottomLeft
        /// Bottom-right corner.
        case bottomRight
        /// Top-left corner.
        case topLeft
        /// Top-right corner.
        case topRight
        
        #if os(macOS)
        /// Corner at `minXMinY`.
        static let minXMinY = Self.bottomLeft
        /// Corner at `maxXMinY`.
        static let maxXMinY = Self.bottomRight
        /// Corner at `minXMaxY`.
        static let minXMaxY = Self.topLeft
        /// Corner at `maxXMaxY`.
        static let maxXMaxY = Self.topRight
        #else
        /// Corner at `minXMinY`.
        static let minXMinY = Self.topLeft
        /// Corner at `maxXMinY`.
        static let maxXMinY = Self.topRight
        /// Corner at `minXMaxY`.
        static let minXMaxY = Self.bottomLeft
        /// Corner at `maxXMaxY`.
        static let maxXMaxY = Self.bottomRight
        #endif
        
        public var description: String {
            switch self {
            case .bottomLeft: return "bottomLeft"
            case .bottomRight: return "bottomRight"
            case .topLeft: return "topLeft"
            case .topRight: return "topRight"
            }
        }

        /// An set of corners.
        public struct Set: OptionSet, Hashable, Codable, CustomStringConvertible {
            /// Corner at `minXMinY`.
            static let minXMinY = Self(rawValue: 1 << 0)
            /// Corner at `maxXMinY`.
            static let maxXMinY = Self(rawValue: 1 << 1)
            /// Corner at `minXMaxY`.
            static let minXMaxY = Self(rawValue: 1 << 2)
            /// Corner at `maxXMaxY`.
            static let maxXMaxY = Self(rawValue: 1 << 3)
            
            #if os(macOS)
            /// Bottom-left corner.
            public static let bottomLeft = minXMinY
            /// Bottom-right corner.
            public static let bottomRight = maxXMinY
            /// Top-left corner.
            public static let topLeft = minXMaxY
            /// Top-right corner.
            public static let topRight = maxXMaxY
            #else
            /// Bottom-left corner
            public static let bottomLeft = minXMaxY
            /// Bottom-right corner.
            public static let bottomRight = maxXMaxY
            /// Top-left corner.
            public static let topLeft = minXMinY
            /// Top-right corner.
            public static let topRight = maxXMinY
            #endif
            
            /// Top corners.
            public static let top: Self = [.topLeft, .topRight]
            /// Bottom corners.
            public static let bottom: Self = [.bottomLeft, .bottomRight]
            /// Left corners.
            public static let left: Self = [.bottomLeft, .topLeft]
            /// Right corners.
            public static let right: Self = [.bottomRight, .topRight]
            /// All corners.
            public static let all: Self = [.topLeft, .topRight,  .bottomLeft, .bottomRight]
            
            public var description: String {
                var strings: [String] = []
                if contains(.bottomLeft) { strings += "bottomLeft" }
                if contains(.bottomRight) { strings += "bottomRight" }
                if contains(.topLeft) { strings += "topLeft" }
                if contains(.topRight) { strings += "topRight" }
                return "[" + strings.sorted().joined(separator: ", ") + "]"
            }
            
            public let rawValue: UInt8
            
            public init(rawValue: UInt8) {
                self.rawValue = rawValue
            }
            
            /// Creates a set of corners containing only the specified corner.
            public init(_ corner: Corner) {
                switch corner {
                case .bottomLeft: self = .bottomLeft
                case .bottomRight: self = .bottomRight
                case .topLeft: self = .topLeft
                case .topRight: self = .topRight
                }
            }
        }
    }
    
    @_disfavoredOverload
    public subscript(corner: Corner) -> CGPoint {
        get {
            switch corner {
            case .topLeft: return topLeft
            case .topRight: return topRight
            case .bottomLeft: return bottomLeft
            case .bottomRight: return bottomRight
            }
        }
        set {
            switch corner {
            case .topLeft: topLeft = newValue
            case .topRight: topRight = newValue
            case .bottomLeft: bottomLeft = newValue
            case .bottomRight: bottomRight = newValue
            }
        }
    }
}

// MARK: - EdgeCorner

extension CGRect {
    /// An enumeration to indicate one edge or corner of a rectangle.
    public enum EdgeCorner: UInt8, Hashable, Codable, CaseIterable, CustomStringConvertible {
        /// Left edge.
        case left
        /// Right edge.
        case right
        /// Top edge.
        case bottom
        /// Bottom edge.
        case top
        /// Bottom-left corner.
        case bottomLeft
        /// Bottom-right corner.
        case bottomRight
        /// Top-left corner.
        case topLeft
        /// Top-right corner.
        case topRight
        
        public var description: String {
            switch self {
            case .left: return "left"
            case .right: return "right"
            case .bottom: return "bottom"
            case .top: return "top"
            case .bottomLeft: return "bottomLeft"
            case .bottomRight: return "bottomRight"
            case .topLeft: return "topLeft"
            case .topRight: return "topRight"
            }
        }
        
        /// Edge at `minX`.
        static let minX = Self.left
        /// Edge at `maxX`.
        static let maxX = Self.right
        #if os(macOS)
        /// Edge at `minY`.
        static let minY = Self.bottom
        /// Edge at `maxY`.
        static let maxY = Self.top
        /// Corner at `minXminY`.
        static let minXminY = Self.bottomLeft
        /// Corner at `minXmaxY`.
        static let minXmaxY = Self.topLeft
        /// Corner at `maxXminY`.
        static let maxXminY = Self.bottomRight
        /// Corner at `maxXmaxY`.
        static let maxXmaxY = Self.topRight
        #else
        /// Edge at `minY`.
        static let minY = Self.top
        /// Edge at `maxY`.
        static let maxY = Self.bottom
        /// Corner at `minXminY`.
        static let minXminY = Self.topLeft
        /// Corner at `minXmaxY`.
        static let minXmaxY = Self.bottomLeft
        /// Corner at `maxXminY`.
        static let maxXminY = Self.topRight
        /// Corner at `maxXmaxY`.
        static let maxXmaxY = Self.bottomRight
        #endif

        
        /// An set of rectangle edges and corners.
        public struct Set: OptionSet, Hashable, Codable, CustomStringConvertible {
            /// Left edge.
            public static let left = minX
            /// Right edge.
            public static let right = maxX
            #if os(macOS)
            /// Bottom edge.
            public static let bottom = minY
            /// Top edge.
            public static let top = maxY
            /// Bottom-left corner.
            public static let bottomLeft = minXMinY
            /// Bottom-right corner.
            public static let bottomRight = maxXMinY
            /// Top-left corner.
            public static let topLeft = minXMaxY
            /// Top-right corner.
            public static let topRight = maxXMaxY
            #else
            /// Bottom edge.
            public static let bottom = maxY
            /// Top edge.
            public static let top = minY
            /// Bottom-left corner
            public static let bottomLeft = minXMaxY
            /// Bottom-right corner.
            public static let bottomRight = maxXMaxY
            /// Top-left corner.
            public static let topLeft = minXMinY
            /// Top-right corner.
            public static let topRight = maxXMinY
            #endif
            
            /// Edge at minimum X.
            static let minX = Self(rawValue: 1 << 0)
            /// Edge at maximum X.
            static let maxX = Self(rawValue: 1 << 1)
            /// Edge at minimum Y.
            static let minY = Self(rawValue: 1 << 2)
            /// Edge at maximum Y.
            static let maxY = Self(rawValue: 1 << 3)
            /// Corner at minimum X and minimum Y.
            static let minXMinY = Self(rawValue: 1 << 4)
            /// Corner at maximum X and minimum Y.
            static let maxXMinY = Self(rawValue: 1 << 5)
            /// Corner at minimum X and maximum Y.
            static let minXMaxY = Self(rawValue: 1 << 6)
            /// Corner at maximum X and maximum Y.
            static let maxXMaxY = Self(rawValue: 1 << 7)
            
            /// All edges.
            public static let edges: Self = [.left, .right, .bottom, .top]
            /// All corners.
            public static let corners: Self = [.bottomLeft, .bottomRight, .topLeft, .topRight]
            /// All edges and corners.
            public static let all: Self = edges + corners
            
            public var description: String {
                var strings: [String] = []
                if contains(.bottomLeft) { strings += "bottomLeft" }
                if contains(.bottom) { strings += "bottom" }
                if contains(.bottomRight) { strings += "bottomRight" }
                if contains(.topLeft) { strings += "topLeft" }
                if contains(.top) { strings += "top" }
                if contains(.topRight) { strings += "topRight" }
                if contains(.left) { strings += "left" }
                if contains(.right) { strings += "right" }
                return "[" + strings.sorted().joined(separator: ", ") + "]"
            }
            
            public let rawValue: UInt8
            
            public init(rawValue: UInt8) {
                self.rawValue = rawValue
            }
            
            /// Creates a set of `EdgeCorners` containing only the specified `edgeCorner`.
            public init(_ edgeCorner: EdgeCorner) {
                switch edgeCorner {
                case .left: self = .left
                case .right: self = .right
                case .bottom: self = .bottom
                case .top: self = .top
                case .bottomLeft: self = .bottomLeft
                case .bottomRight: self = .bottomRight
                case .topLeft: self = .topLeft
                case .topRight: self = .topRight
                }
            }
        }
    }
    
    public subscript(edgeCorner: EdgeCorner) -> CGPoint {
        get {
            switch edgeCorner {
            case .top: return topCenter
            case .left: return centerLeft
            case .bottom: return bottomCenter
            case .right: return centerRight
            case .topLeft: return topLeft
            case .topRight: return topRight
            case .bottomLeft: return bottomLeft
            case .bottomRight: return bottomRight
            }
        }
        set {
            switch edgeCorner {
            case .top: topCenter = newValue
            case .left: centerLeft = newValue
            case .bottom: bottomCenter = newValue
            case .right: centerRight = newValue
            case .topLeft: topLeft = newValue
            case .topRight: topRight = newValue
            case .bottomLeft: bottomLeft = newValue
            case .bottomRight: bottomRight = newValue
            }
        }
    }
}
