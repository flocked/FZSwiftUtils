//
//  Result+.swift
//  
//
//  Created by Florian Zand on 18.04.25.
//

import Foundation

public extension Result {
    /// The success value if the result is [success(_:)](https://developer.apple.com/documentation/swift/result/success(_:)), otherwise `nil`.
    var value: Success? {
        try? get()
    }
    
    /// The failure error if the result is [failure(_:)](https://developer.apple.com/documentation/swift/result/failure(_:)), otherwise `nil`.
    var error: Failure? {
        switch self {
        case .success: return nil
        case .failure(let failure): return failure
        }
    }
}

nonisolated public extension Result {
    /// Returns a new result by applying the specified throwing transformation to the success value.
    @_disfavoredOverload
    func map<NewSuccess>(_ transform: (Success) throws(Failure) -> NewSuccess) -> Result<NewSuccess, Failure> {
        .init(catching: { () throws(Failure) in try transform(get()) })
    }
}

/*
/// Returns a new result by applying the specified throwing transformation to the success value.
@_disfavoredOverload
func map<NewSuccess>(_ transform: (Success) throws -> NewSuccess) -> Result<NewSuccess, Error> {
    .init(catching: { try transform(get()) })
}
 */
