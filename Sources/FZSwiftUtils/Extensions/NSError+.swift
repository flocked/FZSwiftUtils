//
//  NSError+.swift
//
//
//  Created by Florian Zand on 01.06.23.
//

import Foundation

public extension NSError {
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
    convenience init(_ description: String? = nil, failureReason: String? = nil, recoverySuggestion: String? = nil, fileURL: URL? = nil, helpAnchor: String? = nil, domain: String? = nil, code: Int = 1, userInfo: [String: Any]? = nil) {
        var userInfo: [String: Any] = userInfo ?? [:]
        if let description = description {
            userInfo[NSLocalizedDescriptionKey] = description
        }
        if let failureReason = failureReason {
            userInfo[NSLocalizedFailureReasonErrorKey] = failureReason
        }
        if let recoverySuggestion = recoverySuggestion {
            userInfo[NSLocalizedRecoverySuggestionErrorKey] = recoverySuggestion
        }
        if let filePath = fileURL?.path {
            userInfo[NSFilePathErrorKey] = filePath
        }
        if let helpAnchor = helpAnchor {
            userInfo[NSHelpAnchorErrorKey] = helpAnchor
        }
        self.init(domain: domain ?? Bundle.main.bundleIdentifier ?? "NSError.GlobalDomain", code: code, userInfo: userInfo)
    }
    
    /// Creates an `NSError` object for the specified POSIX error code.
    static func posix(_ errorCode: Int32) -> NSError {
        NSError(domain: NSPOSIXErrorDomain, code: Int(errorCode), userInfo: [NSLocalizedDescriptionKey: String(cString: strerror(errorCode))])
    }
    
    /// The file URL which produced this error, or `nil` if not applicable.
    var fileURL: URL? {
        (userInfo[NSFilePathErrorKey] as? String).flatMap(URL.init(fileURLWithPath:))
    }
    
    /// The url which produced this error, or `nil` if not applicable.
    var url: URL? {
        userInfo[NSURLErrorKey] as? URL
    }
}

/*
public extension NSError {
    /**
     Creates an error that can be used for throwing.
     
     - Parameters:
        - description: Description of the error.
        - failureReason: Failure reason.
        - fileURL: The file URL which produced this error, or `nil` if not applicable.
        - recoverySuggestion: Recovery suggestion.
        - recoveryOptions: Titles of buttons appropriate for displaying in an alert panel.
        - helpAnchor: String to display in response to an alert panel help anchor button being pressed.
        - userInfo: The userInfo dictionary for the error.
        - domain: The error domain, or `nil` to use the bundle identifier.
     */
    convenience init(_ description: String, failureReason: String? = nil, fileURL: URL? = nil, recoveryAttempter: ErrorRecoveryAttempter? = nil, helpAnchor: String? = nil, userInfo: [String: Any]? = nil, domain: String? = nil) {
            
        var userInfo: [String: Any] = userInfo ?? [:]
        
        if let recoveryAttempter = recoveryAttempter, !recoveryAttempter.recoveryOptions.isEmpty {
            if let recoverySuggestion = recoveryAttempter.recoverySuggestion {
                userInfo[NSLocalizedRecoverySuggestionErrorKey] = recoverySuggestion
            }
            userInfo[NSRecoveryAttempterErrorKey] = recoveryAttempter
            userInfo[NSLocalizedRecoveryOptionsErrorKey] = recoveryAttempter.recoveryOptions.compactMap({$0.title})
        }
        if let helpAnchor = helpAnchor {
            userInfo[NSHelpAnchorErrorKey] = helpAnchor
        }
        if let failureReason = failureReason {
            userInfo[NSLocalizedFailureReasonErrorKey] = failureReason
        }
        if let filePath = fileURL?.path {
            userInfo[NSFilePathErrorKey] = filePath
        }
        self.init(domain: domain ?? Bundle.main.bundleIdentifier ?? "Error", code: 1, userInfo: userInfo)
    }
    
    
    /// An object that provides methods that allow to attempt to recover from an error.
    @objc(_TtCE12FZSwiftUtilsCSo7NSError22ErrorRecoveryAttempter)class ErrorRecoveryAttempter: NSObject, NSSecureCoding {
        
        public struct Option {
            /// The title of the attempt.
            public let title: String
            
            /// Return a boolean for whether the recovery was successful.
            public let action: () -> Bool
            
           public init(title: String, action: @escaping () -> Bool) {
                self.title = title
                self.action = action
            }
        }
        
        public var recoverySuggestion: String?
        public let recoveryOptions: [Option]
        
        public override func attemptRecovery(fromError error: Error, optionIndex recoveryOptionIndex: Int, delegate: Any?, didRecoverSelector: Selector?, contextInfo: UnsafeMutableRawPointer?) {
            Swift.print("didRecoverSelector",recoveryOptionIndex )

            let didRecover = recoveryOptions[safe: recoveryOptionIndex]?.action() ?? false
            _ = (delegate as AnyObject?)?.perform(didRecoverSelector, with: didRecover, with: contextInfo)
        }
        
        public override func attemptRecovery(fromError error: Error, optionIndex recoveryOptionIndex: Int) -> Bool {
            Swift.print("attemptRecovery",recoveryOptionIndex )
          return recoveryOptions[safe: recoveryOptionIndex]?.action() ?? false
        }
        
        public init(recoverySuggestion: String? = nil, recoveryOptions: [Option]) {
            self.recoverySuggestion = recoverySuggestion
            self.recoveryOptions = recoveryOptions
            super.init()
        }
        
        public static var supportsSecureCoding: Bool {
            false
        }
        
        public func encode(with coder: NSCoder) {
            
        }
        
        public required init?(coder: NSCoder) {
            return nil
        }
    }
}
*/
