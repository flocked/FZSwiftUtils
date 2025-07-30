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
    convenience init(_ description: String? = nil, failureReason: String? = nil, recoverySuggestion: String? = nil, fileURL: URL? = nil, helpAnchor: String? = nil, domain: ErrorDomain, code: Int = 1, userInfo: [String: Any]? = nil) {
        self.init(description, failureReason: failureReason, recoverySuggestion: recoverySuggestion, fileURL: fileURL, helpAnchor: helpAnchor, domain: domain.rawValue, code: code, userInfo: userInfo)
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
    convenience init(_ description: String? = nil, failureReason: String? = nil, recoverySuggestion: String? = nil, fileURL: URL? = nil, helpAnchor: String? = nil, domain: String? = nil, code: ErrorCode, userInfo: [String: Any]? = nil) {
        self.init(description ?? code.description, failureReason: failureReason, recoverySuggestion: recoverySuggestion, fileURL: fileURL, helpAnchor: helpAnchor, domain: domain, code: code.rawValue, userInfo: userInfo)
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
    convenience init(_ description: String? = nil, failureReason: String? = nil, recoverySuggestion: String? = nil, fileURL: URL? = nil, helpAnchor: String? = nil, domain: ErrorDomain? = nil, code: ErrorCode, userInfo: [String: Any]? = nil) {
        self.init(description ?? code.description, failureReason: failureReason, recoverySuggestion: recoverySuggestion, fileURL: fileURL, helpAnchor: helpAnchor, domain: domain?.rawValue, code: code.rawValue, userInfo: userInfo)
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
    
    /// The error domain of a `NSError`.
    struct ErrorDomain: Hashable, RawRepresentable, ExpressibleByStringLiteral {
        /// The error domain.
        public let rawValue: String
        
        /// Creates an error domain.
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        /// Creates an error domain.
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        /// Creates an error domain.
        public init(stringLiteral value: String) {
            self.rawValue = value
        }
        
        /// Cocoa error domain.
        public static let cocoa = Self(NSCocoaErrorDomain)
        
        /// Mach error domain.
        public static let mach = Self(NSMachErrorDomain)

        /// SOCKS error domain.
        public static let streamSocks = Self(NSStreamSOCKSErrorDomain)

        /// SOCKS SSL error domain.
        public static let streamSocksSSL = Self(NSStreamSocketSSLErrorDomain)
        
        /// POSIX/BSD error domain.
        public static let posix = Self(NSPOSIXErrorDomain)
        
        /// Mac OS 9/Carbon error domain.
        public static let osStatus = Self(NSOSStatusErrorDomain)
    }
    
    /// The error code of a `NSError`.
    struct ErrorCode: Hashable, RawRepresentable, ExpressibleByIntegerLiteral {
        /// The error code.
        public let rawValue: Int
            
        /// Creates an error code.
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
            
        /// Creates an error code.
        public init(integerLiteral value: Int) {
            self.rawValue = value
        }
            
        /// Creates an error code.
        public init(_ rawValue: Int) {
            self.rawValue = rawValue
        }
            
        /// Writing failed because of an invalid property list object, or an invalid property list type was specified.
        public static let propertyListWriteInvalid = Self(3852)
            
        /// Unsupported URL scheme for file write operation.
        public static let fileWriteUnsupportedScheme = Self(518)
            
        /// Failure to meet the code‑signing requirement set on an XPC connection.
        public static let xPCConnectionCodeSigningRequirementFailure = Self(4102)
            
        /// Linking failed for the executable.
        public static let executableLink = Self(3588)
            
        /// The minimum validation (key‑value) error code.
        public static let validationErrorMinimum = Self(1024)
            
        /// On‑demand resource exceeded its maximum size.
        public static let bundleOnDemandResourceExceededMaximumSize = Self(4993)
            
        /// Invalid value provided to NSCoder.
        public static let coderInvalidValue = Self(4866)
            
        /// The minimum error code for ubiquitous (iCloud) file errors.
        public static let ubiquitousFileErrorMinimum = Self(4352)
            
        /// Minimum error code for compression errors.
        public static let compressionErrorMinimum = Self(5376)
            
        /// Ubiquitous file not uploaded due to quota being exceeded.
        public static let ubiquitousFileNotUploadedDueToQuota = Self(4354)
            
        /// The runtime environment is incompatible for this executable.
        public static let executableRuntimeMismatch = Self(3586)
            
        /// Handoff of user activity failed.
        public static let userActivityHandoffFailed = Self(4608)
            
        /// The minimum property-list error code (read/write).
        public static let propertyListErrorMinimum = Self(3840)
            
        /// Specified or detected string encoding is unknown or unsupported during file read.
        public static let fileReadUnknownStringEncoding = Self(264)
            
        /// Insufficient permissions to read the specified file.
        public static let fileReadNoPermission = Self(257)
            
        /// The specified file does not exist.
        public static let fileReadNoSuchFile = Self(260)
            
        /// The maximum property-list error code.
        public static let propertyListErrorMaximum = Self(4095)
            
        /// An unknown error occurred during file manager unmount.
        public static let fileManagerUnmountUnknown = Self(768)
            
        /// Attempted to read a corrupted file.
        public static let fileReadCorruptFile = Self(259)
            
        /// NSCoder encountered corrupt data during read.
        public static let coderReadCorrupt = Self(4864)
            
        /// Expected value for a key was not found by NSCoder.
        public static let coderValueNotFound = Self(4865)
            
        /// The minimum error code for cloud sharing-related errors.
        public static let cloudSharingErrorMinimum = Self(5120)
            
        /// The maximum error code for NSCoder-related errors.
        public static let coderErrorMaximum = Self(4991)
            
        /// Not enough free disk space to store on-demand resource data.
        public static let bundleOnDemandResourceOutOfSpace = Self(4992)
            
        /// The version number of the property list cannot be determined.
        public static let propertyListReadUnknownVersion = Self(3841)
            
        /// Compression process failed.
        public static let compressionFailed = Self(5376)
            
        /// The maximum error code for file-related errors.
        public static let fileErrorMaximum = Self(1023)
            
        /// Cannot read file because the URL scheme is unsupported.
        public static let fileReadUnsupportedScheme = Self(262)
            
        /// Failed to load the executable.
        public static let executableLoad = Self(3587)
            
        /// Writing to a property list failed because of a stream error.
        public static let propertyListWriteStream = Self(3851)
            
        /// Decompression failed during streaming.
        public static let decompressionFailed = Self(5377)
            
        /// Cloud sharing failed because storage quota was exceeded.
        public static let cloudSharingQuotaExceeded = Self(5121)
            
        /// The minimum file‑error code, indicating no error condition.
        public static let fileErrorMinimum = Self(0)
            
        /// The base value for executable-related error codes.
        public static let executableErrorMinimum = Self(3584)
            
        /// Cloud sharing failed due to insufficient permissions.
        public static let cloudSharingNoPermission = Self(5124)
            
        /// Generic file write error (unknown cause).
        public static let fileWriteUnknown = Self(512)
            
        /// The file is locked.
        public static let fileLocking = Self(255)
            
        /// Invalid filename prevented reading the file.
        public static let fileReadInvalidFileName = Self(258)
            
        /// File write failed because no space was available.
        public static let fileWriteOutOfSpace = Self(640)
            
        /// The maximum value for formatting-related errors.
        public static let formattingErrorMaximum = Self(2559)
            
        /// User activity could not be continued because user info was too large.
        public static let userActivityHandoffUserInfoTooLarge = Self(4611)
            
        /// The string encoding is not applicable for writing the file.
        public static let fileWriteInapplicableStringEncoding = Self(517)
            
        /// Cloud sharing conflict occurred.
        public static let cloudSharingConflict = Self(5123)
            
        /// Parsing of the property list failed due to corruption.
        public static let propertyListReadCorrupt = Self(3840)
            
        /// Maximum error code for XPC connection issues.
        public static let xPCConnectionErrorMaximum = Self(4224)
            
        /// The remote app timed out during handoff.
        public static let userActivityRemoteApplicationTimedOut = Self(4610)
            
        /// Minimum base for user activity errors.
        public static let userActivityErrorMinimum = Self(4608)
            
        /// Maximum permitted cloud-sharing error code.
        public static let cloudSharingErrorMaximum = Self(5375)
            
        /// The tag specified for on-demand resources is invalid.
        public static let bundleOnDemandResourceInvalidTag = Self(4994)
            
        /// File write failed because the file already exists.
        public static let fileWriteFileExists = Self(516)
            
        /// Architecture mismatch prevented loading executable.
        public static let executableArchitectureMismatch = Self(3585)
            
        /// XPC connection was interrupted.
        public static let xPCConnectionInterrupted = Self(4097)
            
        /// iCloud ubiquity server is not available.
        public static let ubiquitousFileUbiquityServerNotAvailable = Self(4355)
            
        /// Too many participants for cloud sharing.
        public static let cloudSharingTooManyParticipants = Self(5122)
            
        /// The operation was cancelled by the user.
        public static let userCancelled = Self(3072)
            
        /// Invalid reply sent over XPC connection.
        public static let xPCConnectionReplyInvalid = Self(4101)
            
        /// Maximum allowed error code for compression operations.
        public static let compressionErrorMaximum = Self(5503)
            
        /// No write permission for specified file.
        public static let fileWriteNoPermission = Self(513)
            
        /// File too large to read.
        public static let fileReadTooLarge = Self(263)
            
        /// Minimum error for key-value validation.
        public static let keyValueValidation = Self(1024)
            
        /// Base error code for on-demand resource errors.
        public static let bundleErrorMinimum = Self(4992)
            
        /// Maximum validation error code.
        public static let validationErrorMaximum = Self(2047)
            
        /// XPC connection invalid.
        public static let xPCConnectionInvalid = Self(4099)
            
        /// Generic file-read unknown error.
        public static let fileReadUnknown = Self(256)
            
        /// Invalid filename prevented writing the file.
        public static let fileWriteInvalidFileName = Self(514)
            
        /// Maximum permitted error code for user activity operations.
        public static let userActivityErrorMaximum = Self(4863)
            
        /// Attempted write to a read-only volume.
        public static let fileWriteVolumeReadOnly = Self(642)
            
        /// String encoding not applicable for reading the file.
        public static let fileReadInapplicableStringEncoding = Self(261)
            
        /// Executable not loadable.
        public static let executableNotLoadable = Self(3584)
            
        /// Maximum ubiquitous-file error code.
        public static let ubiquitousFileErrorMaximum = Self(4607)
            
        /// Network failure occurred during cloud sharing.
        public static let cloudSharingNetworkFailure = Self(5120)
            
        /// Upper limit for executable error codes.
        public static let executableErrorMaximum = Self(3839)
            
        /// Other unspecified cloud sharing error.
        public static let cloudSharingOther = Self(5375)
            
        /// File-manager failed to unmount because resource is busy.
        public static let fileManagerUnmountBusy = Self(769)
            
        /// Maximum on-demand resource bundle error.
        public static let bundleErrorMaximum = Self(5119)
            
        /// General formatting error occurred.
        public static let formatting = Self(2048)
            
        /// Minimum formatting error code.
        public static let formattingErrorMinimum = Self(2048)
            
        /// iCloud file is unavailable.
        public static let ubiquitousFileUnavailable = Self(4353)
            
        /// No such file exists.
        public static let fileNoSuchFile = Self(4)
            
        /// Error reading property-list due to stream issue.
        public static let propertyListReadStream = Self(3842)
            
        /// Base for XPC connection error codes.
        public static let xPCConnectionErrorMinimum = Self(4096)
            
        /// Handoff cannot continue because the user activity connection is unavailable.
        public static let userActivityConnectionUnavailable = Self(4609)
            
        /// Minimum NSCoder error code.
        public static let coderErrorMinimum = Self(4864)
            
        /// Feature unsupported in current environment.
        public static let featureUnsupported = Self(3328)
        
        var description: String? {
            switch self {
            case .propertyListWriteInvalid:
                return "Writing failed because of an invalid property list object, or an invalid property list type was specified."
            case .fileWriteUnsupportedScheme:
                return "Unsupported URL scheme for file write operation."
            case .xPCConnectionCodeSigningRequirementFailure:
                return "Failure to meet the code‑signing requirement set on an XPC connection."
            case .executableLink:
                return "Linking failed for the executable."
            case .validationErrorMinimum:
                return "The minimum validation (key‑value) error code."
            case .bundleOnDemandResourceExceededMaximumSize:
                return "On‑demand resource exceeded its maximum size."
            case .coderInvalidValue:
                return "Invalid value provided to NSCoder."
            case .ubiquitousFileErrorMinimum:
                return "The minimum error code for ubiquitous (iCloud) file errors."
            case .compressionErrorMinimum:
                return "Minimum error code for compression errors."
            case .ubiquitousFileNotUploadedDueToQuota:
                return "Ubiquitous file not uploaded due to quota being exceeded."
            case .executableRuntimeMismatch:
                return "The runtime environment is incompatible for this executable."
            case .userActivityHandoffFailed:
                return "Handoff of user activity failed."
            case .propertyListErrorMinimum:
                return "The minimum property-list error code (read/write)."
            case .fileReadUnknownStringEncoding:
                return "Specified or detected string encoding is unknown or unsupported during file read."
            case .fileReadNoPermission:
                return "Insufficient permissions to read the specified file."
            case .fileReadNoSuchFile:
                return "The specified file does not exist."
            case .propertyListErrorMaximum:
                return "The maximum property-list error code."
            case .fileManagerUnmountUnknown:
                return "An unknown error occurred during file manager unmount."
            case .fileReadCorruptFile:
                return "Attempted to read a corrupted file."
            case .coderReadCorrupt:
                return "NSCoder encountered corrupt data during read."
            case .coderValueNotFound:
                return "Expected value for a key was not found by NSCoder."
            case .cloudSharingErrorMinimum:
                return "The minimum error code for cloud sharing-related errors."
            case .coderErrorMaximum:
                return "The maximum error code for NSCoder-related errors."
            case .bundleOnDemandResourceOutOfSpace:
                return "Not enough free disk space to store on-demand resource data."
            case .propertyListReadUnknownVersion:
                return "The version number of the property list cannot be determined."
            case .compressionFailed:
                return "Compression process failed."
            case .fileErrorMaximum:
                return "The maximum error code for file-related errors."
            case .fileReadUnsupportedScheme:
                return "Cannot read file because the URL scheme is unsupported."
            case .executableLoad:
                return "Failed to load the executable."
            case .propertyListWriteStream:
                return "Writing to a property list failed because of a stream error."
            case .decompressionFailed:
                return "Decompression failed during streaming."
            case .cloudSharingQuotaExceeded:
                return "Cloud sharing failed because storage quota was exceeded."
            case .fileErrorMinimum:
                return "The minimum file‑error code, indicating no error condition."
            case .executableErrorMinimum:
                return "The base value for executable-related error codes."
            case .cloudSharingNoPermission:
                return "Cloud sharing failed due to insufficient permissions."
            case .fileWriteUnknown:
                return "Generic file write error (unknown cause)."
            case .fileLocking:
                return "The file is locked."
            case .fileReadInvalidFileName:
                return "Invalid filename prevented reading the file."
            case .fileWriteOutOfSpace:
                return "File write failed because no space was available."
            case .formattingErrorMaximum:
                return "The maximum value for formatting-related errors."
            case .userActivityHandoffUserInfoTooLarge:
                return "User activity could not be continued because user info was too large."
            case .fileWriteInapplicableStringEncoding:
                return "The string encoding is not applicable for writing the file."
            case .cloudSharingConflict:
                return "Cloud sharing conflict occurred."
            case .propertyListReadCorrupt:
                return "Parsing of the property list failed due to corruption."
            case .xPCConnectionErrorMaximum:
                return "Maximum error code for XPC connection issues."
            case .userActivityRemoteApplicationTimedOut:
                return "The remote app timed out during handoff."
            case .userActivityErrorMinimum:
                return "Minimum base for user activity errors."
            case .cloudSharingErrorMaximum:
                return "Maximum permitted cloud-sharing error code."
            case .bundleOnDemandResourceInvalidTag:
                return "The tag specified for on-demand resources is invalid."
            case .fileWriteFileExists:
                return "File write failed because the file already exists."
            case .executableArchitectureMismatch:
                return "Architecture mismatch prevented loading executable."
            case .xPCConnectionInterrupted:
                return "XPC connection was interrupted."
            case .ubiquitousFileUbiquityServerNotAvailable:
                return "iCloud ubiquity server is not available."
            case .cloudSharingTooManyParticipants:
                return "Too many participants for cloud sharing."
            case .userCancelled:
                return "The operation was cancelled by the user."
            case .xPCConnectionReplyInvalid:
                return "Invalid reply sent over XPC connection."
            case .compressionErrorMaximum:
                return "Maximum allowed error code for compression operations."
            case .fileWriteNoPermission:
                return "No write permission for specified file."
            case .fileReadTooLarge:
                return "File too large to read."
            case .keyValueValidation:
                return "Minimum error for key-value validation."
            case .bundleErrorMinimum:
                return "Base error code for on-demand resource errors."
            case .validationErrorMaximum:
                return "Maximum validation error code."
            case .xPCConnectionInvalid:
                return "XPC connection invalid."
            case .fileReadUnknown:
                return "Generic file-read unknown error."
            case .fileWriteInvalidFileName:
                return "Invalid filename prevented writing the file."
            case .userActivityErrorMaximum:
                return "Maximum permitted error code for user activity operations."
            case .fileWriteVolumeReadOnly:
                return "Attempted write to a read-only volume."
            case .fileReadInapplicableStringEncoding:
                return "String encoding not applicable for reading the file."
            case .executableNotLoadable:
                return "Executable not loadable."
            case .ubiquitousFileErrorMaximum:
                return "Maximum ubiquitous-file error code."
            case .cloudSharingNetworkFailure:
                return "Network failure occurred during cloud sharing."
            case .executableErrorMaximum:
                return "Upper limit for executable error codes."
            case .cloudSharingOther:
                return "Other unspecified cloud sharing error."
            case .fileManagerUnmountBusy:
                return "File-manager failed to unmount because resource is busy."
            case .bundleErrorMaximum:
                return "Maximum on-demand resource bundle error."
            case .formatting:
                return "General formatting error occurred."
            case .formattingErrorMinimum:
                return "Minimum formatting error code."
            case .ubiquitousFileUnavailable:
                return "iCloud file is unavailable."
            case .fileNoSuchFile:
                return "No such file exists."
            case .propertyListReadStream:
                return "Error reading property-list due to stream issue."
            case .xPCConnectionErrorMinimum:
                return "Base for XPC connection error codes."
            case .userActivityConnectionUnavailable:
                return "Handoff cannot continue because the user activity connection is unavailable."
            case .coderErrorMinimum:
                return "Minimum NSCoder error code."
            case .featureUnsupported:
                return "Feature unsupported in current environment."
            default: return nil
            }
        }
    }
}
