//
//  NSMutableCopying+.swift
//
//
//  Created by Florian Zand on 04.10.26.
//

import Foundation

/// A protocol that mutable objects adopt to provide functional copies of themselves.
public protocol NSMutableCopyable: NSMutableCopying {
    /// The type of the mutable copy.
    associatedtype MutableCopy = Self
    /// Returns a new instance that’s a mutable copy of the receiver.
    func mutableCopied() -> MutableCopy
}

public extension NSMutableCopyable {
    func mutableCopied() -> MutableCopy {
        mutableCopy(with: nil) as! MutableCopy
    }

    /// Returns a new instance that’s a mutable copy of the receiver.
    @_disfavoredOverload
    func mutableCopy() -> MutableCopy {
        mutableCopy(with: nil) as! MutableCopy
    }
}

extension NSArray: NSMutableCopyable {
    public typealias MutableCopy = NSMutableArray
}

extension NSAttributedString: NSMutableCopyable {
    public typealias MutableCopy = NSMutableAttributedString
}

extension NSCharacterSet: NSMutableCopyable {
    public typealias MutableCopy = NSMutableCharacterSet
}

extension NSData: NSMutableCopyable {
    public typealias MutableCopy = NSMutableData
}

extension NSDictionary: NSMutableCopyable {
    public typealias MutableCopy = NSMutableDictionary
}

extension NSIndexSet: NSMutableCopyable {
    public typealias MutableCopy = NSMutableIndexSet
}

extension NSOrderedSet: NSMutableCopyable {
    public typealias MutableCopy = NSMutableOrderedSet
}

extension NSSet: NSMutableCopyable {
    public typealias MutableCopy = NSMutableSet
}

extension NSString: NSMutableCopyable {
    public typealias MutableCopy = NSMutableString
}

extension NSURLRequest: NSMutableCopyable {
    public typealias MutableCopy = NSMutableURLRequest
}

#if os(macOS) || canImport(UIKit)
#if os(macOS)
import AppKit
#else
import UIKit
#endif
extension NSParagraphStyle: NSMutableCopyable {
    public typealias MutableCopy = NSMutableParagraphStyle
}
#endif


#if canImport(AVFoundation)
public import AVFoundation

extension AVAudioMix: NSMutableCopyable {
    public typealias MutableCopy = AVMutableAudioMix
}

extension AVAudioMixInputParameters: NSMutableCopyable {
    public typealias MutableCopy = AVMutableAudioMixInputParameters
}

extension AVComposition: NSMutableCopyable {
    public typealias MutableCopy = AVMutableComposition
}

extension AVMetadataItem: NSMutableCopyable {
    public typealias MutableCopy = AVMutableMetadataItem
}

extension AVMovie: NSMutableCopyable {
    public typealias MutableCopy = AVMutableMovie
}
#endif

#if canImport(Contacts)
import Contacts
extension CNContact: NSMutableCopyable {
    public typealias MutableCopy = CNMutableContact
}

extension CNGroup: NSMutableCopyable {
    public typealias MutableCopy = CNMutableGroup
}

extension CNPostalAddress: NSMutableCopyable {
    public typealias MutableCopy = CNMutablePostalAddress
}
#endif

#if canImport(UserNotifications)
import UserNotifications
extension UNNotificationContent: NSMutableCopyable {
    public typealias MutableCopy = UNMutableNotificationContent
}
#endif

public struct OperatingSystem: RawRepresentable, Hashable, Sendable, ExpressibleByStringLiteral {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
    
    /// macOS.
    public static let macOS: Self = "macOS"
    /// iOS.
    public static let iOS: Self = "iOS"
    /// tvOS.
    public static let tvOS: Self = "tvOS"
    /// watchOS.
    public static let watchOS: Self = "watchOS"
    /// visionOS.
    public static let visionOS: Self = "visionOS"
    /// Linux.
    public static let linux: Self = "Linux"
    /// Windows.
    public static let windows: Self = "Windows"
    
    /// The operating system on which the process is executing.
    public static var current: Self {
        #if os(macOS)
        .macOS
        #elseif os(iOS)
        .iOS
        #elseif os(tvOS)
        .tvOS
        #elseif os(watchOS)
        .watchOS
        #elseif os(visionOS)
        .visionOS
        #elseif os(Linux)
        .linux
        #elseif os(Windows)
        .windows
        #else
        "Unknown"
        #endif
    }
}

extension OperatingSystemVersion: Swift.Comparable, Swift.ExpressibleByIntegerLiteral {
    /// The version of the operating system on which the process is executing.
    public static let current = ProcessInfo.processInfo.operatingSystemVersion
    
    /// Creates an operating system version with the provided major version value.
    public init(majorVersion: Int) {
        self.init(majorVersion: majorVersion, minorVersion: 0, patchVersion: 0)
    }
    
    /// Creates an operating system version with the provided major and minor version value.
    public init(majorVersion: Int, minorVersion: Int) {
        self.init(majorVersion: majorVersion, minorVersion: minorVersion, patchVersion: 0)
    }
    
    /// Creates an operating system version with the provided version values.
    public init(_ majorVersion: Int, _ minorVersion: Int = 0, _ patchVersion: Int = 0) {
        self.init(majorVersion: majorVersion, minorVersion: minorVersion, patchVersion: patchVersion)
    }
    
    /// Creates an operating system version with the provided major version value.
    public init(integerLiteral value: Int) {
        self.init(majorVersion: value)
    }
    
    /// The major and minor version represented as a floating-point value.
    public var float: CGFloat {
        CGFloat(majorVersion) + CGFloat(minorVersion) / pow(10, CGFloat(String(minorVersion).count))
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.majorVersion == rhs.majorVersion &&
        lhs.minorVersion == rhs.minorVersion &&
        lhs.patchVersion == rhs.patchVersion
    }
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.majorVersion, lhs.minorVersion, lhs.patchVersion)
            < (rhs.majorVersion, rhs.minorVersion, rhs.patchVersion)
    }
}

public struct SingleTargetEnvironment: RawRepresentable, ExpressibleByStringLiteral, CaseIterable, Hashable {
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
        guard !Self.allCases.contains(self) else { return }
        Self.allCases.append(self)
    }
    
    public private(set) static var allCases: [Self] = [.macCatalyst, .simulator]
    
    public static var current: Set<Self> {
        Set(allCases.filter(\.isCurrent))
    }
    
    public static let macCatalyst: Self = "macCatalyst"
    public static let simulator: Self = "simulator"

    public init(stringLiteral value: String) {
        self.rawValue = value
    }
    
    public var isCurrent: Bool {
#if targetEnvironment(rawValue)
return true
#endif
        return false
    }
}

public struct TargetEnvironment: OptionSet, Sendable {
    public let rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
        
        #if targetEnvironment(rawValue)
        environment.insert(.simulator)
        #endif
    }
    
    /// The simulator target environment.
    public static let simulator = Self(rawValue: 1 << 0)
    
    /// The Mac Catalyst target environment.
    public static let macCatalyst = Self(rawValue: 1 << 1)
    
    /// The target environment in which the process is executing.
    public static let current: Self = {
        var environment: Self = []
        
        #if targetEnvironment(simulator)
        environment.insert(.simulator)
        #endif
        
        #if targetEnvironment(macCatalyst)
        environment.insert(.macCatalyst)
        #endif
        
        return environment
    }()
}
