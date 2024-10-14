//
//  RuntimeError.swift
//
//
//  Created by Florian Zand on 13.10.24.
//

import Foundation

/// Information about an error condition that can be used for throwing.
public struct RuntimeError: LocalizedError {
    
    /// Description of the error.
    public let errorDescription: String
    
    /// Failure reason.
    public let failureReason: String?
    
    /// Recovery suggestion.
    public let recoverySuggestion: String?
    
    /**
     Creates an error that can be used for throwing.
     
     - Parameters:
        - description: Description of the error.
        - failureReason: Failure reason.
        - recoverySuggestion: Recovery suggestion.
     */
    public init(_ description: String, failureReason: String? = nil, recoverySuggestion: String? = nil) {
        self.errorDescription = description
        self.failureReason = failureReason
        self.recoverySuggestion = recoverySuggestion
    }
}

extension RuntimeError: CustomStringConvertible {
    public var description: String {
        var errorString = "\"\(errorDescription)\""
        if let failureReason = failureReason {
            errorString = errorString + ", failureReason: \"\(failureReason)\""
        }
        if let recoverySuggestion = recoverySuggestion {
            errorString = errorString + ", recoverySuggestion: \"\(recoverySuggestion)\""
        }
        return "RuntimeError(\(errorString))"
    }
}
