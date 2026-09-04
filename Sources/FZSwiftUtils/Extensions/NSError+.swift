//
//  NSError+.swift
//
//
//  Created by Florian Zand on 01.06.23.
//

import Foundation

public struct OSStatusError: CustomNSError, CustomDebugStringConvertible {
    public let ossStatus: OSStatus
    
    public var errorUserInfo: [String : Any] = [:]
    
    public var errorCode: Int {
        Int(ossStatus)
    }
    
    public var debugDescription: String {
        errorUserInfo[NSDebugDescriptionErrorKey] as? String ?? "\(ossStatus)"
    }
    
    public init(status: OSStatus, underlyingError: NSError? = nil) {
        self.ossStatus = status
        self.errorUserInfo[NSDebugDescriptionErrorKey] = SecCopyErrorMessageString(status, nil) as String?
        self.errorUserInfo[NSUnderlyingErrorKey] = underlyingError
    }
    
    public static var errorDomain: String { NSOSStatusErrorDomain }
}

public extension NSError {
    static func osStatus(_ status: OSStatus) -> NSError {
        NSError(domain: .osStatus, code: Int(status))
    }
    
    /**
     Creates an error that can be used for throwing.
     
     - Parameters:
        - description: The description of the error.
        - failureReason: The failure reason.
        - recoverySuggestion: A recovery suggestion.
        - fileURL: The file URL which produced this error.
        - helpAnchor: A string to display in response to an alert panel help anchor button being pressed.
        - domain: The error domain, or `nil` to use the bundle identifier.
        - code: The error code for the error.
        - userInfo: The userInfo dictionary for the error.
     */
    convenience init(_ description: String? = nil, failureReason: String? = nil, recoverySuggestion: String? = nil, fileURL: URL? = nil, helpAnchor: String? = nil, domain: String? = nil, code: Int = 0, userInfo: [String: Any]? = nil) {
        let userInfo = [NSLocalizedDescriptionKey: description,
            NSLocalizedFailureReasonErrorKey: failureReason,
            NSLocalizedRecoverySuggestionErrorKey: recoverySuggestion,
            NSFilePathErrorKey: fileURL?.path,
            NSHelpAnchorErrorKey: helpAnchor].nonNil
        self.init(domain: domain ?? Bundle.main.bundleIdentifier ?? "NSError.GlobalDomain", code: code, userInfo: userInfo)
    }
    
    /**
     Creates an error that can be used for throwing.
     
     - Parameters:
        - description: The description of the error.
        - failureReason: The failure reason.
        - recoverySuggestion: A recovery suggestion.
        - fileURL: The file URL which produced this error.
        - helpAnchor: A string to display in response to an alert panel help anchor button being pressed.
        - domain: The error domain, or `nil` to use the bundle identifier.
        - code: The error code for the error.
        - userInfo: The userInfo dictionary for the error.
     */
    @_disfavoredOverload
    convenience init(_ description: String? = nil, failureReason: String? = nil, recoverySuggestion: String? = nil, fileURL: URL? = nil, helpAnchor: String? = nil, domain: Domain, code: Int = 0, userInfo: [String: Any]? = nil) {
        self.init(description, failureReason: failureReason, recoverySuggestion: recoverySuggestion, fileURL: fileURL, helpAnchor: helpAnchor, domain: domain.rawValue, code: code, userInfo: userInfo)
    }
    
    /*
    /// Creates an `NSError` object for the specified POSIX error code.
    static func posix(_ errorCode: Int32) -> NSError {
        NSError(domain: NSPOSIXErrorDomain, code: Int(errorCode), userInfo: [:])
    }
    */
    
    /// The file URL that produced this error.
    var fileURL: URL? {
        self[NSFilePathErrorKey].flatMap(URL.init(fileURLWithPath:))
    }

    /// The URL that produced this error.
    var url: URL? {
        self[NSURLErrorKey]
    }

    /// The string encoding associated with this error.
    var stringEncoding: String.Encoding? {
        (self[NSStringEncodingErrorKey] as UInt?).map(String.Encoding.init(rawValue:))
    }

    /// The debugging description associated with this error.
    var errorDebugDescription: String? {
        self[NSDebugDescriptionErrorKey]
    }

    /// Returns the value for the specified user info key.
    subscript<Value>(_ key: String) -> Value? {
        userInfo[key] as? Value
    }
    
    /// The domain of the error.
    var errorDomain: Domain {
        Domain(rawValue: domain)
    }
    
    /// The error domain of a [NSError](https://developer.apple.com/documentation/foundation/nserror).
    struct Domain: Hashable, RawRepresentable, ExpressibleByStringLiteral, CustomStringConvertible, CustomDebugStringConvertible {
        /// Cocoa error domain.
        public static let cocoa = Self(rawValue: NSCocoaErrorDomain)
        /// Mach error domain.
        public static let mach = Self(rawValue: NSMachErrorDomain)
        /// SOCKS error domain.
        public static let streamSocks = Self(rawValue: NSStreamSOCKSErrorDomain)
        /// SSL/TLS stream error domain.
        public static let streamSocksSSL = Self(rawValue: NSStreamSocketSSLErrorDomain)
        /// POSIX/BSD error domain.
        public static let posix = Self(rawValue: NSPOSIXErrorDomain)
        /// Mac OS 9/Carbon error domain.
        public static let osStatus = Self(rawValue: NSOSStatusErrorDomain)
        /// URL loading system error domain.
        public static let url = Self(rawValue: NSURLErrorDomain)
        /// Returns the error domain for the specified Objective-C exception.
        public static func objectiveCException(_ exception: NSExceptionName) -> Self {
            Self.init(rawValue: exception.rawValue)
        }
    
        public let rawValue: String
        
        public var description: String {
            switch self {
            case .cocoa: ".cocoa"
            case .posix: ".posix"
            case .mach: ".mach"
            case .osStatus: ".osStatus"
            case .streamSocks: ".streamSocks"
            case .streamSocksSSL: ".streamSocksSSL"
            case .url: ".url"
            default: rawValue
            }
        }
        
        public var debugDescription: String {
            rawValue
        }
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(stringLiteral value: String) {
            self.rawValue = value
        }
    }
}

extension POSIXError {
    /// Initialize an error within this domain with the given code and userInfo.
    public init?(_ code: Int32, userInfo: [String : Any] = [:]) {
        guard let code = POSIXErrorCode(rawValue: code) else { return nil }
        self.init(code, userInfo: userInfo)
    }
    
    /// The POSIX error represented by the current value of `errno`, or `nil` if no error is set.
    public static var current: POSIXError? {
        let code = errno
        guard code != 0 else { return nil }
        return POSIXError(code)
    }
}

public extension POSIXError.Code {
    /// The localized description of the POSIX error code.
    var localizedDescription: String {
        String(cString: strerror(rawValue))
    }

    /// The error code represented by the current nonzero value of `errno`.
    static var current: Self? {
        let value = errno
        guard value != 0 else { return nil }
        return Self(rawValue: value)
    }
}
