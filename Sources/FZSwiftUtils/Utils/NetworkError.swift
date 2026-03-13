//
//  NetworkError.swift
//
//
//  Created by Florian Zand on 13.03.26.
//

import Foundation

/// Error codes returned by Network APIs.
public struct NetworkError: Error, CustomNSError {
    public static let errorDomain = "NetworkError"
    public let errorCode: Int
    public let errorUserInfo: [String : Any]
    
    /// Initialize an error within this domain with the given code and userInfo.
    public init (_ code: Code, userInfo: [String : Any] = [:]) {
        self.errorCode = code.rawValue
        self.errorUserInfo = userInfo
    }
        
    public var localizedDescription: String {
        Code(rawValue: errorCode)!.description + " (\(Self.errorDomain) error \(errorCode).)"
    }

    /// A network error code.
    public enum Code: Int, CustomStringConvertible {
        /// Invalid response.
        case invalidResponse
        /// Bad status code.
        case badStatusCode
        /// Invalid content type.
        case invalidContentType
        /// "Missing data.
        case missingData
        /// Content decoding failed.
        case contentDecodingFailed
        /// Incomplete download.
        case incompleteDownload
        /// Unknown.
        case unknown
        
        public var description: String {
            switch self {
            case .invalidResponse: "Invalid response."
            case .badStatusCode: "Bad status code."
            case .invalidContentType: "Invalid content type."
            case .missingData: "Missing data."
            case .contentDecodingFailed: "Content decoding failed."
            case .incompleteDownload: "Incomplete download."
            case .unknown: "Unknown."
            }
        }
    }
}
